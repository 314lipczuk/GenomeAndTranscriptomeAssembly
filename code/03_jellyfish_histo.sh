#!/bin/bash
#SBATCH --time=15:00:00
#SBATCH --mem=64g
#SBATCH --cpus-per-task=10
#SBATCH --job-name=JellyFishHisto
#SBATCH --partition=pibu_el8
#SBATCH --mail-user=przemyslaw.pilipczuk@students.unibe.ch
#SBATCH --mail-type=end,fail

# Generate k-mer histogram from Jellyfish database.
# - Converts Jellyfish counts into a histogram for modeling (e.g., GenomeScope)
#
# Inputs:
# - $RESULTDIR/jellyfish/results.jf (from 02_jellyfish.sh)
# Outputs:
# - $RESULTDIR/jellyfish/reads.histo

# The log paths are handled in the run.sh and 00_setup.sh, and set automatically

qc_og="$RESULTDIR/jellyfish"
mkdir -p $qc_og

module load Jellyfish/2.3.0-GCC-10.3.0

# -t10: threads for histogram generation
jellyfish histo -t10 "$qc_og/results.jf" > "$qc_og/reads.histo"
