#!/bin/bash

nodepattern=$1
mypswd=$2
poolid=
groupid=
batchid=
az batch account login -g $groupid -n $batchid --verbose

# List the compute nodes running in a pool.
nodeid=`az batch node list --pool-id $poolid -o table | grep _1 | awk '{print $1;}'`

# List remote login connectoin
az batch node remote-login-settings show --pool-id $poolid --node-id $nodeid -o table

# Create the admin user
az batch node user create --is-admin --name adminuser --password $mypswd --pool-id $poolid --node-id $nodeid 
