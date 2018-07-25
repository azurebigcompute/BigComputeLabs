#!/bin/bash

NOW=$(date +%Y%m%d_%H%M%S)
mkdir ~/work/$NOW
for verify in ~/*sv; do
  ln -s ${verify} ~/work/${NOW}/
done

cd ~/work/$NOW

/bin/cat <<EOM >run_verification.pbs
#!/bin/bash
#PBS -l nodes=1:ppn=1
#PBS -l walltime=00:00:59
source /etc/profile.d/cadence.sh
cd ~/work/$NOW
for verify in *.sv; do
    xrun -clean ${verify} -64bit -status
done
EOM

qsub -o ~/work/$NOW/out.log run_verification.pbs