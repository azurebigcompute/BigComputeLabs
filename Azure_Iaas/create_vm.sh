az group create -n hpclab -l westeurope -o table
az vm create --name golden01 --resource-group hpclab --image OpenLogic:CentOS-HPC:7.1:7.1.20170608 --size Standard_H16r --storage-sku Standard_LRS --generate-ssh-keys -o table
az vm list-ip-addresses -o table
