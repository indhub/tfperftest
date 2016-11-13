#!/bin/bash

while [[ $# -gt 1 ]]
do
key="$1"

case $key in
    -m|--model)
    MODEL="$2"
    shift # past argument
    ;;
    -h|--nodes_file)
    NODES_FILE="$2"
    shift # past argument
    ;;
    -r|--remote_dir)
    REMOTE_DIR="$2"
    shift # past argument
    ;;
    -n|--num_nodes)
    NUM_NODES="$2"
    shift # past argument
    ;;
    -g|--gpu_per_node)
    GPU_PER_NODE="$2"
    shift # past argument
    ;;
    -b|--batch_size)
    BATCH_SIZE="$2"
    shift # past argument
    ;;
    *)
          # unknown option
    ;;
esac
shift # past argument or value
done

echo "Compressing model files..."
if [ "$MODEL" == "inceptionv3" ]; then
    model_path="../inception/inception/"
elif [ "$MODEL" == "alexnet" ]; then   
    model_path="../alexnet/"
elif [ "$MODEL" == "resnet" ]; then   
    model_path="../resnet/"
fi

rm model.tar.gz
tar -czvf model.tar.gz $model_path

echo "Copying scripts to remote nodes..."
head -$NUM_NODES $NODES_FILE |
while read line; do
  if [ -z line ]; then continue; fi
    
  arr=( $line )
  host_name=${arr[0]}
  ssh_alias=${arr[1]}
  scp model.tar.gz $ssh_alias:$REMOTE_DIR
  ssh $ssh_alias 'cd '${REMOTE_DIR}' && tar -xvzf model.tar.gz > /dev/null 2>&1' &
done

echo "Generating runners..."
rm -rf gen
mkdir -p gen
script_name=`python generate_runner.py --model=$MODEL --nodes=$NODES_FILE --gen_dir=gen --remote_dir="${REMOTE_DIR}" --num_nodes=$NUM_NODES --gpu_per_node=$GPU_PER_NODE --batch_size=$BATCH_SIZE`

echo "Copying runners..."
if [ "$MODEL" == "inceptionv3" ]; then
    RUNNER_DEST=$REMOTE_DIR/inception/inception/
elif [ "$MODEL" == "alexnet" ]; then   
    RUNNER_DEST=$REMOTE_DIR/alexnet/
elif [ "$MODEL" == "resnet" ]; then   
    RUNNER_DEST=$REMOTE_DIR/resnet/
fi

index=1
head -$NUM_NODES $NODES_FILE |
while read line; do
  arr=( $line )
  ssh_alias=${arr[1]}
  scp gen/${index}.sh ${ssh_alias}:${RUNNER_DEST}/runner.sh
  let "index++"
done

echo "Executing runners..."
head -$NUM_NODES $NODES_FILE |
while read line; do
  tuple=( $line )
  ssh_alias=${tuple[1]}
  ssh ${ssh_alias} "cd ${RUNNER_DEST} && bash runner.sh" &
done

# We could wait for less but there isn't going to be any output for 10 sec anyway
sleep 10

# Run tail to monitor logs
echo "Monitoring logs..."
head -$NUM_NODES $NODES_FILE |
while read line; do
  tuple=( $line )
  ssh_alias=${tuple[1]}
  ssh ${ssh_alias} "tail -f /tmp/worker* | grep --line-buffered '/sec'" &
done

# waitandkill will wake us from sleep after all workers are done
bash waitandkill.sh -n $NUM_NODES -h $NODES_FILE -s $script_name &
sleep 43200 #12 hours

#Workers are done. Collect the logs
echo "Copying logs..."
total_gpus=$(($NUM_NODES*$GPU_PER_NODE))
LOG_DIR=logs/${MODEL}_b${BATCH_SIZE}_g${total_gpus}
rm -rf $LOG_DIR
mkdir -p $LOG_DIR

head -$NUM_NODES $NODES_FILE |
while read line; do
  tuple=( $line )
  ssh_alias=${tuple[1]}
  scp $ssh_alias:/tmp/worker* $LOG_DIR
done

#Get average images/sec
avg=`cat $LOG_DIR/* | grep "examples/sec" | grep -v "step 0" | cut -d'(' -f2 | cut -d' ' -f1 | python average.py`
echo $avg > $LOG_DIR/imagespersec 
echo "Nodes:" $NUM_NODES"; GPUs per node:" $GPU_PER_NODE"; Images/sec:" $avg
