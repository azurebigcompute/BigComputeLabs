#!/bin/bash
# Deploy a new Batch cluster with Ubuntu 

poolid=$1
rgid=
batchid=
batchep=

az batch account login -g $rgid -n $batchid --verbose
az batch pool create --id ${poolid} --image "Canonical:UbuntuServer:16.04.0-LTS" --node-agent-sku-id "batch.node.ubuntu 16.04"  --vm-size Standard_D11 --verbose

# Assign a json to a pool
az batch pool set --pool-id ${poolid} --json-file pool-shipyard.json --verbose

# Resize a pool
az batch pool resize --pool-id ${poolid} --target-dedicated 2 --verbose 

# Remove the old pool if necessary
# az batch pool delete --pool-id ${poolid} 

