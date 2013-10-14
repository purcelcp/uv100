#!/bin/bash -e

#  new_run.sh
#  Tracers
#
#  Created by Paul Gierz on 26.09.13
#

Exp_ID=$1

mkdir -p /uv/user/pgierz/tracers_1p2/expt/expt_${Exp_ID}/nests
mkdir -p /uv/user/pgierz/tracers_1p2/expt/expt_${Exp_ID}/output
mkdir -p /uv/user/pgierz/tracers_1p2/expt/expt_${Exp_ID}/SCRATCH

cp -r /uv/user/pgierz/tracers_1p2/expt/input_defaults /uv/user/pgierz/tracers_1p2/expt/input_${Exp_ID}

echo 'Directories made, remember to change namelist and nest files!'
