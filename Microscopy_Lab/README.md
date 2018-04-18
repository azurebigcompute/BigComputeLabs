## Motivation

The purpose of this project is to demonstrate the possibility of running image processing software for microscopy using Azure Batch. 
Many times the biologists or image processing specialists want to focus on the algorithm, instead of scalability, underlying hardware infrastructure and high availability. [Azure Batch service](https://docs.microsoft.com/en-us/azure/batch/batch-technical-overview) creates and manages a pool of compute nodes (virtual machines), installs the applications you want to run, and schedules jobs to run on the nodes. There is no cluster or job scheduler software to install, manage, or scale. Instead, you use [Batch APIs and tools](https://docs.microsoft.com/en-us/azure/batch/batch-apis-tools), command-line scripts, or the Azure portal to configure, manage, and monitor your jobs.

This project shows how to deploy [Ilastik](http://ilastik.org/download.html) software, but other image processing tools such as [ImageJ](https://imagej.nih.gov/ij/), [Fiji](https://fiji.sc), [Cell Profiler](http://cellprofiler.org), could be easily used as well, provided they have the command line interface. 

These are the result of the processing. The detected cells are depicted in green. Original images are depicted in gray.

![After processing](https://github.com/lmiroslaw/azure-batch-ilastik/blob/master/resources/demoSmall.gif)

## Ilastik on Azure
In this project [Drosophila 3D+t](http://data.ilastik.org/drosophila.zip) data set from [Hufnagel Grup, EMBL Heidelberg](http://www.embl.de/research/units/cbb/hufnagel/) is used. You can download the input images as follows:
> wget http://data.ilastik.org/drosophila.zip

Once downloaded extract the files and identify *pixelClassification.ilp* file with the algorithm as well as the input image *drosophila_00-49.h5*. To show the scaling possibilities we have created a multiple copies of the *drosophila_00-49.h5*. Each task analyzes one copy of the image on a separate VM by executing:

> ./run_ilastik.sh --headless --project=pixelClassification.ilp drosophila_00-49.h5 --export_source="Simple Segmentation" --output_filename_format="../out/{nickname}{slice_index}.tiff" --output_format="multipage tiff sequence"

## Preparation phase

We are assuming you already created the Storage Account as well as the Batch Account using Azure Portal or Azure CLI (see the Troubleshooting section). Following preparation steps must be executed.

1. Update the deployment script [deploy_script.sh](https://github.com/lmiroslaw/azure-batch-ilastik/blob/master/deploy_script.sh)
2. Update the [JSON file](https://github.com/lmiroslaw/azure-batch-ilastik/blob/master/pool-shipyard.json) with the reference to the  dependencies and the deployment script. Update the container name in the *blobSource* tag. 
3. Compress and upload a tar ball with the pixelClassification.ilp and [run_task.sh](https://github.com/lmiroslaw/azure-batch-ilastik/blob/master/run_task.sh) to the Blob storage by executing [00.Upload.sh](https://github.com/lmiroslaw/azure-batch-ilastik/blob/master/00.Upload.sh).

```bash
 tar -cf runme.tar pixelClassification.ilp run_task.sh
 az storage blob upload -f runme.tar --account-name shipyarddata --account-key longkey== -c drosophila --name runme.tar
 az storage blob upload -f deploy_script.sh --account-name shipyarddata --account-key longkey== -c drosophila --name deploy_script.sh
```
The logic included in a separate runme.tar file and the input data are uploaded separately. The example includes a single input file .h5 that is uploaded multiple times. This way we can simulate real scenario with multiple input files: 

```
for k in {1..2}
do
az storage blob upload -f drosophila_00-49.h5 --account-name shipyarddata --account-key longkey== -c drosophila --name drosophila_00-49_$k.h5
 done
```

4. Edit the script and provide missing Batch Account Name, poolid and execute the script [01.redeploy.sh](https://github.com/lmiroslaw/azure-batch-ilastik/blob/master/01.redeploy.sh) as follows:
```
./01.redeploy.sh ilastik
```
where 'ilastik' is the pool name.  The script creates the pool:
```
poolid=ilastik
GROUPID=demorg
BATCHID=matlabb
az batch account login -g $GROUPID -n $BATCHID

az batch pool create --id $poolid --image "Canonical:UbuntuServer:16.04.0-LTS" --node-agent-sku-id "batch.node.ubuntu 16.04"  --vm-size Standard_D11 --verbose
```

assigns a json to a pool
```
az batch pool set --pool-id $poolid --json-file pool-shipyard.json 
```

and resizes the pool. This is the moment when the VMs are provisioned and the deploy_script.sh executes on each machine.
```
az batch pool resize --pool-id $poolid --target-dedicated 2 
```

## Execution Phase

5. Edit the script and provide missing data and execute the script [02.run_job.sh](https://github.com/lmiroslaw/azure-batch-ilastik/blob/master/02.run_job.sh) as follows:
```
./02.run_job.sh ilastik
```

The scripts creates a job and $k=2$ tasks on a pool called *ilastik*. Each task calls [run_task.sh](https://github.com/lmiroslaw/azure-batch-ilastik/blob/master/run_task.sh) that in turns analyzes a single .h5 file.
```
az batch job create --id $JOBID --pool-id $poolid 
for k in {1..2} 
  do 
    echo "starting task_$k ..."
    az batch task create --job-id $JOBID --task-id "task_$k" --command-line "/mnt/batch/tasks/shared/run_task.sh $k > out.log"
  done

```

6. Once the calculation is ready download the results to your local machine by:
```
03.download_results.sh $jobid
```
where $jobid identifies the job. You can find out this parameter while running [02.run_job.sh](https://github.com/lmiroslaw/azure-batch-ilastik/blob/master/02.run_job.sh), from Azure Portal or from BatchLabs.

You can visualize the results in [ImageJ](https://imagej.nih.gov/ij/), [Fiji](https://fiji.sc) or image processing software of your choice.

## Troubleshooting

We encourage to use [BatchLabs](https://github.com/Azure/BatchLabs) for monitoring purposes. In addition, these set of commands will help to deal with problems during the execution.

Run the script and create the admin user on the first node
```
04.diagnose.sh mypassword
```

* Remove the job
> az batch job delete  --job-id $jobid  --account-endpoint $batchep --account-name $batchid --yes

* We can check the status of the pool to see when it has finished resizing.
> az batch pool show --pool-id $poolid  --account-endpoint $batchep --account-name $batchid

* List the compute nodes running in a pool.
> az batch node list --pool-id $poolid --account-endpoint $batchep --account-name $batchid -o table

* List remote login connections for a specific node, for example *tvm-3550856927_1-20170904t111707z* 
> az batch node remote-login-settings show --pool-id ilastik --node-id tvm-3550856927_1-20170904t111707z --account-endpoint $batchep --account-name $batchid -o table

* Remove the pool
> az batch pool delete --pool-id $poolid  --account-endpoint $batchep --account-name $batchid

* Create the resource group and storage account. For example:
 ```
 az group create -n tilastik -l westeurope
 az storage account create -n ilastiksstorage -l westeurope -g tilastik
```
* Get the connection string for the Azure Storage
> az storage account show-connection-string -n ilastiksstorage -g tilastik

* Create the azure batch service
> az batch account create -n bilastik -g tilastik

### Acknowledgement

Data courtesy of Lars Hufnagel, EMBL Heidelberg

http://www.embl.de/research/units/cbb/hufnagel/
