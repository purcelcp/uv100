#!/bin/bash -e

#   Scripts for: Tracers
#
#   This script will take a RAW mpiom output file, select the velocity u, v, and w,
#   and cut it into chunks of 599 timesteps. Afterward, it sends the file to matlab
#   for rotation and regridding. Finally, the nest link script is called.
#
#   Paul Gierz, October 2013
#   AWI Bremerhaven

fin=$1
ntimesteps=`cdo -s ntime ${fin}`
nfiles=`python -c "from math import ceil; print ceil($ntimesteps/599.0)"`
echo "There will be ${nfiles} file made"

for i in $(seq 1 $nfiles);
do
    echo $i
    # NOTE: cdo needs 1/599 not 0/599, thereafter 600/1199 etc etc
    echo `expr ($i - 1) * 599` to `expr (($i - 1) * 599) + 599` #FIXME this might be better in python?
# the cdo command cdo splitsel,30 makes chunks that can run in matlab in 1 hour
done
