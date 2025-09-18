#!/bin/bash
#SBATCH --time=15:00:00
#SBATCH --mem=64g
#SBATCH --cpus-per-task=4
#SBATCH --job-name=JellyFishCount
#SBATCH --partition=pibu_el8
#SBATCH --mail-user=przemyslaw.pilipczuk@students.unibe.ch
#SBATCH --mail-type=end,fail

# The log paths are handled in the run.sh and 00_setup.sh, and set automatically

qc_og="$RESULTDIR/jellyfish"
mkdir -p $qc_og

module load Jellyfish/2.3.0-GCC-10.3.0

jellyfish count -t10 -s 5G -C -m 21 -o "$qc_og/results.jf" \
  <(zcat "$RESULTDIR/fastp/dna/fastp.fastq.gz")
