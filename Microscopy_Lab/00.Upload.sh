#!/bin/bash
storageAccountName=storagename
storageKey=ABClongkey==
$containerName=drosophila
tar -cf runme.tar pixelClassification.ilp run_task.sh
echo "Uploading runme.tar"
az storage blob upload -f runme.tar --account-name $storageAccountName --account-key $storageKey -c $containerName --name runme.tar
cd ..
echo "Uploading deployment script"
az storage blob upload -f deploy_script.sh --account-name $storageAccountName --account-key $storageKey -c $containerName --name deploy_script.sh

for k in {1..2} 
  do
    echo "Uploading the $k input file"
    az storage blob upload -f drosophila_00-49.h5 --account-name $storageAccountName --account-key $storageKey -c $containerName --name drosophila_00-49_$k.h5
  done

