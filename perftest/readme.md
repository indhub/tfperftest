### What do these scripts do?

These scripts make is easy to measure the images/sec that TF processes under a synchronous distributed training setting. 

### What model is used for training?
Inception v3, Alexnet and Resnet. Inception v3 is based on https://github.com/tensorflow/models/tree/master/inception. AlexNet is based on https://github.com/tensorflow/tensorflow/blob/master/tensorflow/models/image/alexnet/alexnet_benchmark.py. Fully connected layers were added at the end to complete the network. Resnet is based on https://github.com/indhub/tfperftest/tree/master/resnet. Some code changes have been done to build Resnet 152 model.

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

Step 3: Run runscalabilitytest.sh

Example: 

    bash runscalabilitytest.sh -h nodes -m inceptionv3 -g 16 -b 32 -r /tmp/ -x 128

where,

-h: node file described in step 1.

-m: Name of the model to run. Can be 'inceptionv3', 'alexnet' or 'resnet'.

-g: number of GPUs in each node to use for training. 

-b: mini batch size per GPU.

-r: a directory in the remote nodes where to copy the scripts and run the training (/tmp/ should work).

-x: Maximum GPUs to use for scalability test. 


Example:

bash runscalabilitytest.sh -h nodes -m inceptionv3 -g 16 -b 32 -r /tmp/ -x 128

will run inceptionv3 on 1, 2, 4, 8, ..... 128 GPUs, recording the images processed per second in each of those runs and tabulate that data as output into logs/inceptionv3_b32.csv (same data will be plotted in logs/inceptionv3_b32.svg). The script use the hosts listed in 'nodes' to run the training. The script will assume each of those hosts have 16 GPUs in them. The script will use a mini batch size of 32.



## What does the script output?

Images processed per second is writed under logs directory as inceptionv3_b[batch_size].csv, alexnet_b[batch_size].csv and resnet_b[batch_size].csv. Same data is plotted in graph in inceptionv3_b[batch_size].svg, alexnet_b[batch_size].svg and resnet_b[batch_size].svg.

