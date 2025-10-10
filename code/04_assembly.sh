#!/bin/bash
#SBATCH --time=15:00:00
#SBATCH --mem-per-cpu=32g
#SBATCH --cpus-per-task=16
#SBATCH --job-name=Assemble
#SBATCH --partition=pibu_el8
#SBATCH --mail-user=przemyslaw.pilipczuk@students.unibe.ch
#SBATCH --mail-type=end,fail
#SBATCH --array=0-3

# Genome and transcriptome assembly with multiple tools via SLURM array.
# - SLURM array indexes select the assembler:
#   0: Flye (HiFi genome), 1: hifiasm (HiFi genome),
#   2: LJA (HiFi genome), 3: Trinity (RNA-seq transcriptome)
# - Each assembler writes to its own subdirectory under $RESULTDIR
#
# Inputs:
# - $RESULTDIR/fastp/dna/out.fastq.gz (HiFi DNA, for genome assemblers)
# - $RESULTDIR/fastp/rna1/out.fastq[.gz], $RESULTDIR/fastp/rna2/out.fastq[.gz] (for Trinity)
#   Note: filenames/extensions must match outputs produced in 01_qc.sh.
# Outputs:
# - $RESULTDIR/{flye,hifiasm,LJA,Trinity}/...

SATI="$SLURM_ARRAY_TASK_ID"

if [ "$SATI" -eq 0 ]; then
# flye assembly
OD="$RESULTDIR/flye"
mkdir -p $OD
# Flye assembly
apptainer exec \
  --bind /data \
  /containers/apptainer/flye_2.9.5.sif \
  flye --pacbio-hifi "$RESULTDIR/fastp/dna/out.fastq.gz" \
  -t 16 \
  -o "$OD"
fi

if [ "$SATI" -eq 1 ]; then
# hifiasm assembly
OD="$RESULTDIR/hifiasm"
mkdir -p $OD
# hifiasm assembly; converts GFA to FASTA after run
apptainer exec \
  --bind /data \
  /containers/apptainer/hifiasm_0.25.0.sif \
  hifiasm "$RESULTDIR/fastp/dna/out.fastq.gz" \
  -t 16 \
  -o "$OD/result.asm"

  awk '/^S/{print ">"$2"\n"$3}' "$OD/result.asm.bp.p_ctg.gfa" | fold > "$OD/assembly_primary_contig.fa"
fi

if [ "$SATI" -eq 2 ]; then
# LJA assembly
OD="$RESULTDIR/LJA"
mkdir -p $OD
# LJA assembly
apptainer exec \
  --bind /data \
  /containers/apptainer/lja-0.2.sif \
  lja --reads "$RESULTDIR/fastp/dna/out.fastq.gz" \
  -t 16 \
  -o "$OD"
fi


if [ "$SATI" -eq 3 ]; then
# LJA assembly
OD="$RESULTDIR/Trinity"

mkdir -p $OD
# Trinity RNA-seq assembly (paired-end)
apptainer exec \
  --bind /data \
  /containers/apptainer/trinity_2.15.2.sif \
  Trinity \
  --left "$RESULTDIR/fastp/rna1/out.fastq" \
  --right "$RESULTDIR/fastp/rna2/out.fastq" \
  --no_normalize_reads \
  --seqType fq \
  --CPU 16 \
  --max_memory 64G \
  --output "$OD"
fi
