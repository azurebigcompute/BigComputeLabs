# Azure Remote Visualisation Lab
* Microsoft EMEA Big Compute (HPC) Team - <mailto:EMEAGBBBigComputeTSP @ microsoft.com>
* Initial versions by Karl Podesta, February 2018

## 1. Introduction

### 1.1  The Lab
This is a technical lab to help you get started with remote visualisation (remote GPU workstations) on Azure. You will log in to Azure, create a VM (Linux or Windows), enable GPU drivers, remotely connect to the GUI/desktop using VNC or RDP, and run some GPU tools.  The Lab should take approx 30 minutes to complete.  

Please share any thoughts, feedback, or improvements - this is a work in progress, and we want to make sure it helps you to get started in the right way with using Azure for remote! 

### 1.2  Remote Workstations 
In HPC, our focus is on performance.  This is not just for during a simulation - but also before and afterwards.  Typically there is a model we need to prepare, or a result we need to analyse.  For example, manipulating a 3D model, or displaying a combination of data sets, requires a dedicated GPU.  So a workstation with a GPU is often a key part of a HPC workflow - before, during, or after the HPC job.  Luckily, there is a range of GPUs available on VMs in Azure.  

### 1.3  GPUs (Graphical Processing Units)
In Azure at present, we use GPUs from NVIDIA.  We have these available in our N-series VMs.  There are a few types of these VMs: 
- NV (Visualisation) - these are the VM types used for remote workstations, and the type we focus on here. 
- NC (Compute) - these are also called "GPGPUs", and are used for HPC calculations
- ND (Deep Learning) - these are similar to NC, and are used for HPC calculations, but specialised for Deep Learning & AI workloads (i.e. training models). 

Here we focus on the first type - for visualisation. 

## 2. Create a VM in Azure

We will follow these steps: 
1. Login to Azure
2. Create a VM (Linux)
3. Login to VM 

### 2.1 Login to Azure
You can access Azure via <a href="https://portal.azure.com">https://portal.azure.com</a>.  You may have a subscription already.  If not, you can sign up for a subscription. 

### 2.2 Create a VM (Linux)

### 2.3 Login to VM


## 3. Configuring the GPU

After we create & log in to our VM in Azure, we need to configure the VM to use the GPU, in addition to setting up remote desktop access. 

### 3.1 Installing GPU drivers

Firstly, follow instructions on the Azure documentation (N Series Linux Driver Setup): <a href="https://docs.microsoft.com/en-us/azure/virtual-machines/linux/n-series-driver-setup">https://docs.microsoft.com/en-us/azure/virtual-machines/linux/n-series-driver-setup</a>.  On this page, go to "Install GRID Drivers for NV VMs", and then to "CentOS or Red Hat Enterprise Linux". 

In brief, and for convenience, these steps are: 

1. Update the Linux Kernel
	sudo yum update
	sudo yum install kernel-devel
	sudo rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
	sudo yum install dkms

2. Disable ("blacklist") the Nouveau driver (this is an Open Source driver, not NVIDIA)
Create a file /etc/modprobe.d/nouveau.conf ("nano /etc/modprobe.d/nouveau.conf") with the following contents: 
	blacklist nouveau
	blacklist lbm-nouveau

3. Reboot the VM, and install the NVIDIA Grid driver
	wget -O NVIDIA-Linux-x86_64-384.111-grid.run https://go.microsoft.com/fwlink/?linkid=849941  
	chmod +x NVIDIA-Linux-x86_64-384.111-grid.run
	sudo ./NVIDIA-Linux-x86_64-384.111-grid.run
When you are asked if you want to run nvidia-xconfig to update your X configuration, say Yes. When the driver installation is complete, check that the file /etc/X11/xorg.conf has been updated with the details of your NVIDIA driver. 
	nvidia-xconfig --query-gpu-info
	cat /etc/X11/xorg.conf

4. Update the NVIDIA Grid Conf file (configuration)
	sudo cp /etc/nvidia/gridd.conf.template /etc/nvidia/gridd.conf
Add the following to /etc/nvidia/gridd.conf:
	IgnoreSP=TRUE

5. Verify driver installation

### 3.2 Configuring Graphical Desktop

In this step, we will ensure the Linux Graphical Desktop software (GNOME) and graphical capabilities (X server) is installed, and is configured to boot at startup.  We will also set up a capability to connect to the desktop remotely, using the "x11vnc" software (VNC). 

Edit /etc/gdm/custom.conf to reflect the following:

	[daemon]
	KillInitClients=false

	[security]
	DisallowTCP=false


Edit /etc/gdm/Init/Default, and just before exit 0 (last line): 

	/bin/x11vnc -o /var/log/x11vnc.log -display :0 -many -bg

Set Linux to boot up with the Graphical Service by default, then reboot:

	systemctl disable firstboot
	systemctl disable firstconfig
	systemctl set-default graphical.target
	reboot

### 3.3 Remotely connect (VNC)

### 3.4 Enabling multiple users

## 4. Using Graphical Applications

### 4.1 3D utilities
- glxgears
- heaven

### 4.2 GPU benchmarking


## 5. Other GPU desktop tools

This section discusses some 3rd party applications that are commonly used together with remote workstations.  Your organisation may already use one or more of these in various scenarios. 

### 5.1 Teradici
Teradici (<a href="https://www.teradici.com/">https://www.teradici.com/</a>) is 3rd party software that uses PCoIP protocol to achieve optimised performance for a remote workstation desktop.  This protocol only sends "changed pixels" between the remote desktop (e.g. in the cloud), and the desktop client (e.g. on a user site).  Combined with other performance optimisations, this allows for a secure (encrypted), colour correct, and highly performant interactivity, even over poor Internet connections. Teradici have hardware and software clients available. 

### 5.2 Citrix
Citrix (<a href="https://www.citrix.com/">https://www.citrix.com/</a>) is one of the most common tools used for remote desktops, and the Citrix HDX products are typically used for remote workstation or HPC desktop requirements.  

### 5.3 NoMachine
NoMachine (<a href="https://www.nomachine.com/">https://www.nomachine.com/</a>) uses the NX protocol to deliver remote desktops.  It also consists of server & client software, is cross platform, and is freely available, with a license cost for additional features.  

### 5.4 Others

- HP RGS
- NICE DCV
- ThinLinc
- Mechdyne
- Frame
- Workspot

## 6. Links & References
* <a href="https://docs.microsoft.com/en-us/azure/virtual-machines/linux/n-series-driver-setup">Azure N Series Driver Setup (Linux)</a> - Azure documentation for N-series driver setup for Linux. 
* <a href="https://docs.microsoft.com/en-us/azure/storage/storage-use-azcopy">AzCopy (Windows)</a> - command line tool for copying data to Azure, fast!
* <a href="https://docs.microsoft.com/en-us/azure/storage/storage-use-azcopy-linux">AzCopy (Linux)</a> - command line tool for copying data to Azure, fast!


