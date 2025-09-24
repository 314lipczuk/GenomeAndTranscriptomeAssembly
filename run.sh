#!/bin/bash

source code/00_setup.sh
NOW=$(date +"%d-%m-%Y_%H_%M")
echo $LOGDIR
sbatch --output="$LOGDIR/o%a_%x_$NOW-%J" --error="$LOGDIR/e_%a%x_$NOW-%J" $@