#!/bin/bash
exit 0
source /etc/profile.d/cadence.sh

jetpack log "Copying XCELIUM to vFXT."

mkdir -p $CADENCE_INSTALL/cadence
rsync --inplace -av  $TEMP_DIR/cadence $CADENCE_INSTALL/

jetpack log "Finished copying XCELIUM to vFXT."
