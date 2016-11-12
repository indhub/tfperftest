#!/bin/bash

while [[ $# -gt 1 ]]
do
key="$1"

case $key in
    -h|--nodes_file)
    NODES_FILE="$2"
    shift # past argument
    ;;
    -m|--model)
    MODEL="$2"
    shift # past argument
    ;;
    -g|--gpu_per_machine)
    MAX_GPU_PER_MACHINE="$2"
    shift # past argument
    ;;
    -b|--batch_size)
    BATCH_SIZE="$2"
    shift # past argument
    ;;
    -r|--remote_dir)
    REMOTE_DIR="$2"
    shift # past argument
    ;;
    -x|--max_gpu)
    MAX_GPUS="$2"
    shift # past argument
    ;;
    *)
          # unknown option
    ;;
esac
shift # past argument or value
done

ngpu=1
while [ "$ngpu" -le "$MAX_GPUS" ]; do
    echo "Running with $ngpu GPUs"
    
    num_machines=$(($ngpu/$MAX_GPU_PER_MACHINE))
    if ! ((num_machines % $MAX_GPU_PER_MACHINE)); then
        num_machines=$((num_machines + 1))
    fi
    
    gpu_per_machine=$MAX_GPU_PER_MACHINE
    if ((ngpu < MAX_GPU_PER_MACHINE)); then
        gpu_per_machine=$ngpu
    fi
    
    bash runtest.sh -m $MODEL -h $NODES_FILE -r $REMOTE_DIR -n $num_machines -g $gpu_per_machine -b $BATCH_SIZE
    
    ngpu=$(($ngpu * 2))
done
