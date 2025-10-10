#!/bin/bash

source code/00_setup.sh
NOW=$(date +"%d-%m-%Y_%H_%M")
echo $LOGDIR

# filenames that when sorted it shows relevant files together.
sbatch --output="$LOGDIR/%x-[$NOW]-[%a]-OUT-[%J]" --error="$LOGDIR/%x-[$NOW]-[%a]-ERR-[%J]" $@