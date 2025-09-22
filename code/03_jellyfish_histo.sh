#!/bin/bash
#SBATCH --time=15:00:00
#SBATCH --mem=64g
#SBATCH --cpus-per-task=10
#SBATCH --job-name=JellyFishHisto
#SBATCH --partition=pibu_el8
#SBATCH --mail-user=przemyslaw.pilipczuk@students.unibe.ch
#SBATCH --mail-type=end,fail

# The log paths are handled in the run.sh and 00_setup.sh, and set automatically

qc_og="$RESULTDIR/jellyfish"
mkdir -p $qc_og

module load Jellyfish/2.3.0-GCC-10.3.0

jellyfish histo -t10 "$qc_og/results.jf" > "$qc_og/reads.histo"

