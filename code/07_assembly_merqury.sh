#!/bin/bash
#SBATCH --time=48:00:00
#SBATCH --mem=64g
#SBATCH --cpus-per-task=16
#SBATCH --job-name=AssemblyMerqury
#SBATCH --partition=pibu_el8
#SBATCH --array=0-2
#SBATCH --mail-user=przemyslaw.pilipczuk@students.unibe.ch
#SBATCH --mail-type=end,fail

# Assembly quality evaluation using Merqury.
# - Builds a k-mer database from reads (once) using meryl
# - Runs Merqury to estimate QV, k-mer completeness, and spectra-cn plots
# - SLURM array index selects assembly to evaluate
#
# Inputs:
# - $BASEDIR/reads.fastq.gz (HiFi reads for k-mer DB)
# - Assembly FASTA from $RESULTDIR/{flye,hifiasm,LJA}
# Outputs:
# - $RESULTDIR/merqury/<name>/ with reports and plots

RESULTDIR=/data/users/ppilipczuk/GenomeAndTransAss/results
BASEDIR=/data/users/ppilipczuk/GenomeAndTransAss
export MERQURY="/usr/local/share/merqury"
export PATH=$MERCURY:$PATH

ASSEMBLIES=(
  "$RESULTDIR/flye/assembly.fasta"
  "$RESULTDIR/hifiasm/assembly_primary_contig.fa"
  "$RESULTDIR/LJA/k501/disjointigs.fasta"
)
NAMES=("flye" "hifi" "lja")

INPUT=${ASSEMBLIES[$SLURM_ARRAY_TASK_ID]}
NAME=${NAMES[$SLURM_ARRAY_TASK_ID]}

OD="$RESULTDIR/merqury/$NAME"
mkdir -p "$OD/logs"

# Step 1: Build k-mer DB from reads once
if [ ! -d "$RESULTDIR/reads.meryl" ]; then
  echo "Counting k-mers from reads..."
  apptainer exec --bind /data /containers/apptainer/meryl_1.4.1.sif \
    meryl k=23 count "$BASEDIR/reads.fastq.gz" output "$RESULTDIR/reads.meryl"
fi

# Step 2: Run Merqury inside the output directory
cd "$OD"
apptainer exec --bind /data /containers/apptainer/merqury_1.3.sif \
  merqury.sh "$RESULTDIR/reads.meryl" "$INPUT" "${NAME}_merqury"

echo "Merqury done for $NAME"
