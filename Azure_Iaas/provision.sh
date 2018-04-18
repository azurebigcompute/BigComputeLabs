
ssh-keygen -t dsa -f ./testcluster.key -P ""

export SSH_IP=`az vmss list-instance-connection-info --name lab-vmss --resource-group hpclab | grep instance | awk -F "\"" '{print $4}' | awk -F ":" '{print $1}' | uniq`
export SSH_PORTS=`az vmss list-instance-connection-info --name lab-vmss --resource-group hpclab | grep instance | awk -F "\"" '{print $4}' | awk -F ":" '{print $2}'`

echo "ssh ip address is $SSH_IP"


for i in $SSH_PORTS; do
  LOCAL_IP=`echo $i - 49996 | bc`
  LOCAL_NAME=`echo $i - 49999 | bc`
  scp -o "StrictHostKeyChecking no" -P $i ./testcluster.key* $SSH_IP:~/.ssh/
  scp -o "StrictHostKeyChecking no" -P $i ./local_provision.sh $SSH_IP:~/
  ssh -o "StrictHostKeyChecking no" $SSH_IP -p $i "cp ~/.ssh/testcluster.key ~/.ssh/id_rsa; cp ~/.ssh/testcluster.key.pub ~/.ssh/id_rsa.pub"
  ssh -o "StrictHostKeyChecking no" $SSH_IP -p $i "cat ~/.ssh/testcluster.key.pub >> ~/.ssh/authorized_keys"
  ssh -o "StrictHostKeyChecking no" $SSH_IP -p $i "echo 'StrictHostKeyChecking no' > ~/.ssh/config; chmod 600 ~/.ssh/*; chmod 755 ./local_provision.sh"
  ssh -o "StrictHostKeyChecking no" $SSH_IP -p $i -t "sudo hostname node$LOCAL_NAME ; sleep 20"
  ssh -o "StrictHostKeyChecking no" $SSH_IP -p $i -t "sudo ./local_provision.sh"
done
