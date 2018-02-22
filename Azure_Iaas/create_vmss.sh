az vmss create --name lab-vmss --resource-group hpclab --image OpenLogic:CentOS-HPC:7.1:7.1.20170608  --vm-sku Standard_H16r --storage-sku Standard_LRS --instance-count 2 --generate-ssh-keys 
./show_vmss.sh


