

sudo yum -y install git nfs-utils

sudo echo "export INTELMPI_ROOT=/opt/intel/impi/2017.2.174" >> /etc/bashrc
sudo echo "export I_MPI_ROOT=/opt/intel/compilers_and_libraries_2017.2.174/linux/mpi" >> /etc/bashrc
sudo echo "source /opt/intel/impi/2017.2.174/bin64/mpivars.sh" >> /etc/bashrc
sudo echo "export I_MPI_FABRICS=dapl I_MPI_DAPL_PROVIDER=ofa-v2-ib0 I_MPI_DYNAMIC_CONNECTION=0" >> /etc/bashrc

if [ `hostname -s` == "node1" ]; then
echo "I am node1!!!"
sudo echo "/opt 10.0.0.0/16(rw)" > /etc/exports
sudo mkdir /scratch
sudo umount /mnt/resource 
sudo mount /dev/sdb1 /scratch
sudo echo "/scratch 10.0.0.0/16(rw)" >> /etc/exports
sudo service nfs restart 
fi


if [ `hostname -s` != "node1" ]; then
sudo mount node1:/opt /opt
sudo mkdir /scratch
sudo mount node1:/scratch /scratch
fi


