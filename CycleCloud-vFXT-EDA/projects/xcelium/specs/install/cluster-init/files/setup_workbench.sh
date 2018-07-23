#!/bin/bash


mkdir -p /mnt/vfxt/${USER}/work
ln -s /mnt/vfxt/${USER}/work/ ~/work

cp ${CADENCE_INSTALL}/work/* ~/work
