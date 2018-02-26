# Azure HPC Data Transfer Lab
* Microsoft EMEA Big Compute (HPC) Team - <mailto:EMEAGBBBigComputeTSP @ microsoft.com>
* Initial versions by Karl Podesta, February 2018

## 1. Introduction

### 1.1  The Lab
This is a technical lab to help you get started with HPC data tranfer on Azure.  We will investigate various options for transferring data to, from, and inside Azure - with a focus on performance.  We will try some of the free methods for accelerating data transfer.  The Lab should take approx 60 minutes to complete.  

Please share any thoughts, feedback, or improvements - this is a work in progress, and we want to make sure it helps you to get started in the right way with using Azure for HPC data transfer! 

### 1.2  Data Transfer for HPC
HPC jobs are typically concerned with data at (1) input, (2) job execution, (3) output, (4) archive.  Also a concern is the movement of data between these stages, e.g. during a workflow.  Depending on the industry or application, the volume of this data will vary greatly.  From KB text files (e.g. input to a financial risk model), to TB or PB size files required at all stages (e.g. Seismic Processing in Oil & Gas, or Animation/Rendering). There will also be different performance requirements at all stages.   

If you think of Azure as just another Data Centre where you will run your HPC job - how do you get data *into* Azure, *out of* Azure, and how will data be stored and moved around if required?  

## 2. Review of the methods

### 2.1 Connection
The following connection types are common for an "online" data transfer over the Internet. 
- Standard Internet Connection
- Virtual Private Network (VPN)
- Dedicated Connection - Microsoft ExpressRoute

### 2.2 Protocols

### 2.3 Tools

### 2.4 Practices

- Data Tiers

### 2.5 Storage

- Blobs
- Files
- Disks

### 2.6 Security

## 3. Accelerated Transfers

### 3.1 Open Source Tools


### 3.2 Azure Tools

- Storage Explorer
- AZBB
- DDT

### 3.3 3rd Party Applications

- Aspera
- Signiant
- FileCatalyst

## 4. Managed Transfers

## 5. Controls, Notifications, Costs

## 6. Comparisons 

## 7. Links & References
* <a href="https://docs.microsoft.com/en-us/azure/batch/">Azure Batch Service</a> - High level information about the Azure Batch service
* <a href="https://docs.microsoft.com/en-us/azure/storage/storage-use-azcopy">AzCopy (Windows)</a> - command line tool for copying data to Azure, fast!
* <a href="https://docs.microsoft.com/en-us/azure/storage/storage-use-azcopy-linux">AzCopy (Linux)</a> - command line tool for copying data to Azure, fast!


