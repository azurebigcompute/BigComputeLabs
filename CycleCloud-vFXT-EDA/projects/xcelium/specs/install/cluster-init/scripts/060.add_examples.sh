#!/bin/bash
set -ex

source /etc/profile.d/cadence.sh

mkdir -p $CADENCE_INSTALL/examples
chmod a+x $CADENCE_INSTALL/examples
cp $CYCLECLOUD_SPEC_PATH/files/*sv $CADENCE_INSTALL/examples/
chmod a+r $CADENCE_INSTALL/examples/*sv

cp $CYCLECLOUD_SPEC_PATH/files/*sh $CADENCE_INSTALL/examples/
chmod a+x $CADENCE_INSTALL/examples/*sh