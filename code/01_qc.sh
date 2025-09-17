#!/bin/bash

#SBATCH --time=15:00:00
#SBATCH --mem=4g
#SBATCH --cpus-per-task=4
#SBATCH --job-name=QualityControl
#SBATCH --partition=pibu_el8
#SBATCH --mail-user=przemyslaw.pilipczuk@students.unibe.ch
#SBATCH --mail-type=end,fail

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

# These run independently - therefore we can paralellize them 
#  using bash jobs: '&' at the end of a command to make it into a job, 
# and 'wait' command to wait for them to finish before starting next step.
wait
# Sequential version of this script ran for: 15m

apptainer exec \
  --bind /data \
  /containers/apptainer/fastp_0.23.2--h5f740d0_3.sif \
  fastp -Q -i "$BASEDIR/reads.fastq.gz" -h "$fp/dna/report.html" -o "$fp/dna/out"  &

apptainer exec \
  --bind /data \
  /containers/apptainer/fastp_0.23.2--h5f740d0_3.sif \
  fastp -i "$BASEDIR/rna_data/ERR754081_1.fastq.gz" -h "$fp/rna1/report.html" \
  -o "$fp/rna1/out"  &

apptainer exec \
  --bind /data \
  /containers/apptainer/fastp_0.23.2--h5f740d0_3.sif \
  fastp -i "$BASEDIR/rna_data/ERR754081_2.fastq.gz" -h "$fp/rna2/report.html" \
  -o "$fp/rna2/out" &

  wait