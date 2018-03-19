#!/bin/sh

# This script exutes in /mnt/batch/tasks/startup/wd
# elevation: adminuser

apt-get install -y unzip 
# Retrieve the runtask 
tar xf runme.tar -C $AZ_BATCH_NODE_SHARED_DIR

# Retrieve Ilastik
wget http://files.ilastik.org/ilastik-1.2.2-Linux.tar.bz2 -P $AZ_BATCH_NODE_SHARED_DIR
cd $AZ_BATCH_NODE_SHARED_DIR # Note: changing a working directory to /mnt/batch/tasks/shared 
chmod o+x run_task.sh # make sure you can run the script
tar xjf ilastik-1.*-Linux.tar.bz2

#$AZ_BATCH_NODE_SHARED_DIR points to /mnt/batch/tasks/shared 

