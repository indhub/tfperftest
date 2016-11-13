#!/bin/bash

while [[ $# -gt 1 ]]
do
key="$1"

case $key in
    -m|--model)
    MODEL="$2"
    shift # past argument
    ;;
    -b|--batch_size)
    BATCH_SIZE="$2"
    shift # past argument
    ;;
    -l|--log_dir)
    LOG_DIR="$2"
    shift # past argument
    ;;
    -g|--gpu_list)
    GPU_LIST="$2"
    shift # past argument
    ;;
    -f|--table_file)
    TABLE_FILE="$2"
    shift # past argument
    ;;
    *)
          # unknown option
    ;;
esac
shift # past argument or value
done

echo "Writing table to $TABLE_FILE"
rm $TABLE_FILE 2>/dev/null

for gpu in $(echo $GPU_LIST | sed "s/,/ /g")
do
    echo ${gpu},`cat ${LOG_DIR}/${MODEL}_b${BATCH_SIZE}_g${gpu}/imagespersec` >> $TABLE_FILE
done
