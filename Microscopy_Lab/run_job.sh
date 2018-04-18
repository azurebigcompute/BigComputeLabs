#!/bin/bash
prefix=ilastikjob
suffix=$(date +%s)  # The "+%s" option to 'date' is GNU-specific.
JOBID=$prefix-$suffix
echo "Creating job ${JOBID}..."
az batch job create --id $JOBID --pool-id ilastikdemo --account-endpoint https://matlabb.westeurope.batch.azure.com --account-name matlabb
for k in {1..2} do
  echo "starting task ${k}..."
  az batch task create --job-id $JOBID --task-id "task_${k}" --command-line "/mnt/batch/tasks/shared/run_task.sh $k" --account-endpoint https://matlabb.westeurope.batch.azure.com --account-name matlabb
 done

echo "done."
