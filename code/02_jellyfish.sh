#!/bin/bash
#SBATCH --time=15:00:00
#SBATCH --mem=64g
#SBATCH --cpus-per-task=10
#SBATCH --job-name=JellyFishCount
#SBATCH --partition=pibu_el8
#SBATCH --mail-user=przemyslaw.pilipczuk@students.unibe.ch
#SBATCH --mail-type=end,fail

# Count k-mers from filtered DNA reads using Jellyfish.
# - Builds a canonical k=21 k-mer database from fastp-processed reads
# - Uses a 5G hash (-s) and 10 threads (-t)
#
# Inputs:
# - $RESULTDIR/fastp/dna/out.fastq.gz (from 01_qc.sh)
# Outputs:
# - $RESULTDIR/jellyfish/results.jf (Jellyfish k-mer DB)

# The log paths are handled in the run.sh and 00_setup.sh, and set automatically

qc_og="$RESULTDIR/jellyfish"
mkdir -p $qc_og

module load Jellyfish/2.3.0-GCC-10.3.0

# -C: count canonical k-mers (strand-collapsed)
# -m 21: k-mer length 21 (tuned for ~135 Mb genome here)
# -s 5G: hash size; adjust if memory allows to reduce collisions
# -t10: threads
jellyfish count -t10 -s 5G -C -m 21 -o "$qc_og/results.jf" \
  <(zcat "$RESULTDIR/fastp/dna/out.fastq.gz")
