#!/bin/bash
set -ex

CADENCE_INSTALL=$(jetpack config cadence.install_dir)/cadence \
    || CADENCE_INSTALL=$(jetpack config cyclecloud.mounts.vfxt.mountpoint)/cadence \
    || CADENCE_INSTALL=$(jetpack config gluster.mountpoint)/cadence \
    || CADENCE_INSTALL=/opt/tools/cadence

mkdir -p $CADENCE_INSTALL/examples
chmod a+x $CADENCE_INSTALL/examples
cp $CYCLECLOUD_SPEC_PATH/files/*sv $CADENCE_INSTALL/examples/
chmod a+r $CADENCE_INSTALL/examples/*sv
