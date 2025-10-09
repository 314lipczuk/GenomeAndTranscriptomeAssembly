#!/bin/bash
#SBATCH --time=15:00:00
#SBATCH --mem=64g
#SBATCH --cpus-per-task=4
#SBATCH --job-name=QualityControl
#SBATCH --partition=pibu_el8
#SBATCH --mail-user=przemyslaw.pilipczuk@students.unibe.ch
#SBATCH --mail-type=end,fail

# Quality control for DNA and RNA reads using FastQC, MultiQC, and fastp.
# - Runs FastQC on input DNA and RNA FASTQ files
# - Aggregates reports with MultiQC
# - Trims/filters reads with fastp (DNA single-end; RNA paired-end)
# - Uses background jobs (&) and wait to parallelize independent steps
#
# Inputs:
# - $BASEDIR/reads.fastq.gz (HiFi DNA reads)
# - $BASEDIR/RNA_data/ERR754081_1.fastq.gz and ERR754081_2.fastq.gz (RNA reads)
# Outputs:
# - $RESULTDIR/qc_original: FastQC reports
# - $RESULTDIR/fastp: fastp reports and filtered FASTQs (dna, rna1, rna2)
# Notes:
# - Log paths are configured by run.sh and 00_setup.sh
# - Requires Apptainer containers for tools on the cluster

# The log paths are handled in the run.sh and 00_setup.sh, and set automatically

#module load FastQC/0.11.9-Java-11
#module load MultiQC/1.11-foss-2021a
qc_og="$RESULTDIR/qc_original"
mkdir $qc_og

apptainer exec \
  --bind /data \
  /containers/apptainer/fastqc-0.12.1.sif \
  fastqc "$BASEDIR/reads.fastq.gz" -o $qc_og &

apptainer exec \
  --bind /data \
  /containers/apptainer/fastqc-0.12.1.sif \
  fastqc "$BASEDIR/RNA_data/ERR754081_2.fastq.gz" -o $qc_og &

apptainer exec \
  --bind /data \
  /containers/apptainer/fastqc-0.12.1.sif \
  fastqc "$BASEDIR/RNA_data/ERR754081_1.fastq.gz" -o "$qc_og" &
  
fp="$RESULTDIR/fastp"
mkdir $fp
mkdir "$fp/dna"
mkdir "$fp/rna1"
mkdir "$fp/rna2"

# These run independently — we parallelize them with background jobs (&)
# and synchronize with 'wait' before starting the next stage.
wait
# Sequential version of this script ran for: 16m
# Paralell: 11m
# So I'm leaving the paralell in.

# MultiQC aggregates all FastQC results into one report
apptainer exec \
  --bind /data \
  /containers/apptainer/multiqc-1.19.sif \
  "$qc_og"

apptainer exec \
  --bind /data \
  /containers/apptainer/fastp_0.23.2--h5f740d0_3.sif \
  fastp -Q -i "$BASEDIR/reads.fastq.gz" -h "$fp/dna/report.html" -o "$fp/dna/out.fastq.gz"  &

apptainer exec \
  --bind /data \
  /containers/apptainer/fastp_0.23.2--h5f740d0_3.sif \
  fastp -i "$BASEDIR/RNA_data/ERR754081_1.fastq.gz" -I "$BASEDIR/RNA_data/ERR754081_2.fastq.gz" -h "$fp/rna1/report.html" \
  -o "$fp/rna1/out.fastq.gz" -O "$fp/rna2/out.fastq.gz"  &


wait
