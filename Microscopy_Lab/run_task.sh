#!/bin/bash

# see Task factory
# sudo not needed because of the elevation as Admin, see: https://social.msdn.microsoft.com/Forums/en-US/87b19671-1bdf-427a-972c-2af7e5ba82d9/installing-applications-and-staging-data-on-batch-compute-nodes?forum=azurebatch

#This file downloads the input file from Azure Blob and runs Ilastik
# Working directory: $AZ_BATCH_NODE_SHARED_DIR
echo There are $# arguments to $0: $*

filenamein=drosophila_00-49
cd $( dirname "${BASH_SOURCE[0]}" )
echo Downloading ${filenamein}_$1
wget https://shipyarddata.blob.core.windows.net/drosophila/${filenamein}_$1.h5

# Problem: pixelClassification.ilp seems to be hardcoded because it accepts only the original filename (=drosophila_00-49)
cp ${filenamein}_$1.h5 ${filenamein}.h5
#chown $USER -R ilastik-1.*-Linux
echo Running ilastik ...
cd ilastik-1.*-Linux
./run_ilastik.sh --headless --project=../pixelClassification.ilp ../${filenamein}.h5 --export_source="Simple Segmentation" --output_filename_format="../out/{nickname}{slice_index}.tiff" --output_format="multipage tiff sequence"

cp ../out/*.tiff $AZ_BATCH_TASK_WORKING_DIR
cp log.out $AZ_BATCH_TASK_WORKING_DIR

#Saving to: 'drosophila_00-49_1.h5'
#Atention: the ilp file expects the file name drosophila_00-49.h5. That is why the file name is updated.
