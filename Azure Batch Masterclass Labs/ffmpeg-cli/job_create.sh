az batch job create --template job-ffmpeg.json --account-name mybatchhugo --account-endpoint https://mybatchhugo.westeurope.batch.azure.com

#az batch job create \
#	--account-name python \
#	--account-endpoint https://python.westeurope.batch.azure.com \
#	--pool-id pythonPool \
#	--id pythonJob \
#	#--image "Canonical:UbuntuServer:16.04.0-LTS:latest" \
#	#--node-agent-sku-id "batch.node.ubuntu 16.04" \
#	#--vm-size "STANDARD_D3_V2" \
#	#--target-dedicated-nodes 2 \
#
