az batch pool create --template pool-ffmpeg.json --account-name mybatchhugo --account-endpoint https://mybatchhugo.westeurope.batch.azure.com

#az batch pool create \
#	--account-name python \
#	--account-endpoint https://python.westeurope.batch.azure.com \
#	--id pythonPool \
#	--image "Canonical:UbuntuServer:16.04.0-LTS:latest" \
#	--node-agent-sku-id "batch.node.ubuntu 16.04" \
#	--vm-size "STANDARD_D3_V2" \
#	--target-dedicated-nodes 2 \
#
