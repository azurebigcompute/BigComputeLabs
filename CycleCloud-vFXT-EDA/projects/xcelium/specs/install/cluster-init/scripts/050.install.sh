#!/bin/bash
set -ex

### installing to vfxt can be problematic
#Not enough disk space to install component 
# in selected install directory:
#     /mnt/vfxt/cadence
#    Space Available : -9223372036854775808 Bytes
#    Space Required : 26722 Bytes

source /etc/profile.d/cadence.sh

TEMP_DIR=/mnt/resource
if [ ! -d "$TEMP_DIR" ]; then
  TEMP_DIR=/tmp
fi
mkdir $TEMP_DIR/cadence

CACHE_DIR=/mnt/resource
if [ ! -d "$CACHE_DIR" ]; then
  CACHE_DIR=/tmp
fi

yum -y install java-1.8.0-openjdk

mkdir -p /root/.iscape/root
jetpack download unknown80httpbasic /root/.iscape/root

jetpack download IScape04.23-s012lnx86.t.Z /root/ 
cd /root
tar -xf IScape04.23-s012lnx86.t.Z

jetpack log "Starting XCELIUM installation."
mkdir -p $CADENCE_INSTALL
./iscape/bin/iscape.sh -batch majorAction=install \
    cacheDirectory=$CACHE_DIR \
    SourceLocation='http://sw.cadence.com/is/XCELIUM1710/lnx86/Base' \
    ArchiveDirectory=$CACHE_DIR \
    InstallDirectory=$TEMP_DIR/cadence

rsync -av  $TEMP_DIR/cadence $CADENCE_INSTALL

jetpack log "XCELIUM installation complete."

exit 0
./iscape/bin/iscape.sh -batch majorAction=install \
    cacheDirectory=/tmp \
    SourceLocation='http://sw.cadence.com/is/LCU/lnx86/Tools_LCU04.25.004'  \
    ArchiveDirectory=/tmp \
    InstallDirectory=/opt/lcu
