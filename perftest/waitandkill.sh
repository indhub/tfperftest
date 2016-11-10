while [[ $# -gt 1 ]]
do
key="$1"

case $key in
    -n|--num_nodes)
    NUM_NODES="$2"
    shift 
    ;;
    -h|--hosts_file)
    HOSTS_FILE="$2"
    shift 
    ;;
    -s|--script_name)
    SCRIPT_NAME="$2"
    shift 
    ;;
    *)
          # unknown option
    ;;
esac
shift # past argument or value
done


while :
do
    worker_running=0

    sleep 30
    
    while read line; do

        tuple=( $line )
        ssh_alias=${tuple[1]}

        nump=`ssh $ssh_alias "ps -ef | grep '$SCRIPT_NAME' | grep -v grep  | wc -l"`

        if [ "$nump" -le 1 ]
            then
                : #echo $ssh_alias " is done"
        else
            #echo $ssh_alias " is not done"
            worker_running=1
        fi

    done < $HOSTS_FILE
    
    if [ "$worker_running" == 0 ] ; then
      echo "All workers are done. Terminate everything."
      
        head -$NUM_NODES $HOSTS_FILE |
        while read line; do
          tuple=( $line )
          ssh_alias=${tuple[1]}

          ssh -n $ssh_alias "pkill tail"
          ssh -n $ssh_alias "ps -ef | grep '$SCRIPT_NAME' |  grep -v grep | xargs echo | cut -d' ' -f2 | xargs kill -9"
        done      
        
        ps -ef | grep "sleep 43200" |  grep -v grep | xargs echo | cut -d' ' -f2 | xargs kill -9

      exit 0
    fi
    
done

