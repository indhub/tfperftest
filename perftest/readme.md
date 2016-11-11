### What do these scripts do?

These scripts make is easy to measure the images/sec that TF can process under a synchronous distributed training setting. 

### What model is used for training?
Inception v3 and Alexnet. Inception v3 is based on https://github.com/tensorflow/models/tree/master/inception. AlexNet is based on https://github.com/tensorflow/tensorflow/blob/master/tensorflow/models/image/alexnet/alexnet_benchmark.py. Fully connected layers were added at the end to complete the network.

### What data is used for training?

Since these scripts only calculate the images processed per second, the scripts use randomly generated synthetic data similar to how it is done here: https://github.com/tensorflow/tensorflow/blob/master/tensorflow/models/image/alexnet/alexnet_benchmark.py

### How to run the scripts?

Step 1: Create a 'nodes' file containing the list of machines to be used in the test. Each line in the nodes file corresponds to one machine. Each line has the DNS name of the machine and the ssh alias that can be used to connect to that machine without entering password.Here is the format of the file:

    host1.example.com node1
    host2.example.com node1
    .
    .
    .
    hostn.example.com node3

Here is an example config from ~/.ssh/config to create an ssh alias:

    Host node1
        HostName host1.example.com
        port 22
        user ubuntu
        IdentityFile /Users/my_uname/my_ssh_key.pem

Step 2: Checkout https://github.com/indhub/tfperftest.git and CD to 'perftest' (https://github.com/indhub/tfperftest/tree/master/perftest) directory.

Step 3: Run runtest.sh.

Example: 

    bash runtest.sh -m inceptionv3 -h nodes -r /tmp/ -n 2 -g 2 -b 32

where,

-m: Name of the model to run. Can be 'inceptionv3' or 'alexnet'

-r: a directory in the remote nodes where to copy the scripts and run the training. 

-n: number of nodes to use in training. 

-g: number of GPUs in each node to use for training. 

-b: batch size per GPU.

-n: node file described in step 1.

## What does the script output?

Here is a sample output:

    f45c89940f03:perftest thangakr$ bash runtest.sh -h nodes -r /tmp/ -n 2 -g 2 -b 32
    Compressing Inception v3 files...
    Copying scripts to remote nodes...
    inception.tar.gz                                                                                                                                                                       100%  463KB 463.5KB/s   00:00    
    inception.tar.gz                                                                                                                                                                       100%  463KB 463.5KB/s   00:00    
    Generating runners...
    Copying runners...
    1.sh                                                                                                                                                                                   100% 1421     1.4KB/s   00:00    
    2.sh                                                                                                                                                                                   100% 1421     1.4KB/s   00:00    
    Executing runners...
    Monitoring logs...
    INFO:tensorflow:Worker 2: 2016-11-07 22:58:36.546566: step 0, loss = 13.10(3.3 examples/sec; 9.590  sec/batch)
    INFO:tensorflow:Worker 3: 2016-11-07 22:58:37.794479: step 0, loss = 13.18(3.4 examples/sec; 9.503  sec/batch)
    INFO:tensorflow:Worker 1: 2016-11-07 22:58:35.740424: step 0, loss = 13.13(3.3 examples/sec; 9.720  sec/batch)
    INFO:tensorflow:Worker 2: 2016-11-07 22:58:38.200165: step 0, loss = 13.11(19.4 examples/sec; 1.652  sec/batch)
    INFO:tensorflow:Worker 3: 2016-11-07 22:58:39.516269: step 0, loss = 9.54(18.6 examples/sec; 1.719  sec/batch)
    INFO:tensorflow:Worker 1: 2016-11-07 22:58:37.570758: step 0, loss = 9.34(17.5 examples/sec; 1.829  sec/batch)
    INFO:tensorflow:Worker 0: 2016-11-07 22:58:40.775078: step 0, loss = 13.07(3.1 examples/sec; 10.194  sec/batch)
    INFO:tensorflow:Worker 1: 2016-11-07 22:59:40.763573: step 30, loss = 9.50(17.8 examples/sec; 1.800  sec/batch)
    INFO:tensorflow:Worker 0: 2016-11-07 22:59:40.763701: step 30, loss = 8.83(17.8 examples/sec; 1.794  sec/batch)
    INFO:tensorflow:Worker 3: 2016-11-07 22:59:43.005218: step 30, loss = 8.30(17.8 examples/sec; 1.796  sec/batch)
    INFO:tensorflow:Worker 2: 2016-11-07 22:59:43.009688: step 30, loss = 9.78(17.8 examples/sec; 1.800  sec/batch)
    INFO:tensorflow:Worker 1: 2016-11-07 23:00:38.856076: step 60, loss = 6.54(15.8 examples/sec; 2.029  sec/batch)
    INFO:tensorflow:Worker 0: 2016-11-07 23:00:38.856217: step 60, loss = 6.71(15.8 examples/sec; 2.028  sec/batch)
    INFO:tensorflow:Worker 2: 2016-11-07 23:00:41.105758: step 60, loss = 6.63(15.7 examples/sec; 2.036  sec/batch)
    INFO:tensorflow:Worker 3: 2016-11-07 23:00:41.109002: step 60, loss = 6.60(15.7 examples/sec; 2.033  sec/batch)
    INFO:tensorflow:Worker 0: 2016-11-07 23:01:46.370813: step 90, loss = 5.75(15.7 examples/sec; 2.035  sec/batch)
    INFO:tensorflow:Worker 1: 2016-11-07 23:01:46.370896: step 90, loss = 5.57(15.7 examples/sec; 2.034  sec/batch)
    INFO:tensorflow:Worker 3: 2016-11-07 23:01:48.617834: step 90, loss = 5.58(15.7 examples/sec; 2.036  sec/batch)
    INFO:tensorflow:Worker 2: 2016-11-07 23:01:48.619283: step 90, loss = 5.61(15.8 examples/sec; 2.026  sec/batch)
    INFO:tensorflow:Worker 0: 2016-11-07 23:02:42.879941: step 120, loss = 5.30(17.4 examples/sec; 1.837  sec/batch)
    INFO:tensorflow:Worker 1: 2016-11-07 23:02:42.880375: step 120, loss = 5.27(17.4 examples/sec; 1.839  sec/batch)
    INFO:tensorflow:Worker 2: 2016-11-07 23:02:45.122123: step 120, loss = 5.31(17.5 examples/sec; 1.833  sec/batch)
    INFO:tensorflow:Worker 3: 2016-11-07 23:02:45.132570: step 120, loss = 5.27(17.3 examples/sec; 1.847  sec/batch)
    INFO:tensorflow:Worker 1: 2016-11-07 23:03:38.981646: step 150, loss = 5.25(17.6 examples/sec; 1.816  sec/batch)
    INFO:tensorflow:Worker 0: 2016-11-07 23:03:38.981859: step 150, loss = 5.26(17.5 examples/sec; 1.826  sec/batch)
    INFO:tensorflow:Worker 2: 2016-11-07 23:03:41.223426: step 150, loss = 5.23(17.5 examples/sec; 1.824  sec/batch)
    INFO:tensorflow:Worker 3: 2016-11-07 23:03:41.223559: step 150, loss = 5.23(17.5 examples/sec; 1.824  sec/batch)
    INFO:tensorflow:Worker 0: 2016-11-07 23:04:38.883009: step 180, loss = 5.21(16.6 examples/sec; 1.924  sec/batch)
    INFO:tensorflow:Worker 1: 2016-11-07 23:04:38.883333: step 180, loss = 5.26(16.7 examples/sec; 1.918  sec/batch)
    INFO:tensorflow:Worker 2: 2016-11-07 23:04:41.124629: step 180, loss = 5.22(16.7 examples/sec; 1.920  sec/batch)
    INFO:tensorflow:Worker 3: 2016-11-07 23:04:41.124639: step 180, loss = 5.20(16.6 examples/sec; 1.923  sec/batch)
    All workers are done. Terminate everything.
    runtest.sh: line 90: 58516 Killed: 9               sleep 43200
    Copying logs...
    worker0                                                                                                                                                                                100%   43KB  42.8KB/s   00:01    
    worker1                                                                                                                                                                                100%  112KB 111.6KB/s   00:00    
    worker2                                                                                                                                                                                100%  112KB 111.6KB/s   00:01    
    worker3                                                                                                                                                                                100%  112KB 111.6KB/s   00:00    
    Nodes: 2; GPUs per node: 2; Images/sec: 16.808

The scripts also write this data into the 'log' folder.




