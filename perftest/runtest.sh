#!/bin/bash

while [[ $# -gt 1 ]]
do
key="$1"

case $key in
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

echo "Compressing Inception v3 files..."
rm inception.tar.gz
tar -czvf inception.tar.gz ../inception/inception/

echo "Copying scripts to remote nodes..."
head -$NUM_NODES $NODES_FILE |
while read line; do
  if [ -z line ]; then continue; fi
    
  arr=( $line )
  host_name=${arr[0]}
  ssh_alias=${arr[1]}
  scp inception.tar.gz $ssh_alias:$REMOTE_DIR
  ssh $ssh_alias 'cd '${REMOTE_DIR}' && tar -xvzf inception.tar.gz > /dev/null 2>&1' &
done

echo "Generating runners..."
rm -rf gen
mkdir -p gen
python generate_runner.py --nodes=$NODES_FILE --gen_dir=gen --remote_dir="${REMOTE_DIR}" --num_nodes=$NUM_NODES --gpu_per_node=$GPU_PER_NODE --batch_size=$BATCH_SIZE

echo "Copying runners..."
RUNNER_DEST=$REMOTE_DIR/inception/inception/

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
bash waitandkill.sh -n $NUM_NODES -h $NODES_FILE &
sleep 43200 #12 hours

#Workers are done. Collect the logs
echo "Copying logs..."
LOG_DIR=logs/m${NUM_NODES}g${GPU_PER_NODE}
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
