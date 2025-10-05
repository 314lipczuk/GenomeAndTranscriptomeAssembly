#!/bin/bash
#SBATCH --time=48:00:00
#SBATCH --mem=64g
#SBATCH --cpus-per-task=16
#SBATCH --job-name=Quast
#SBATCH --partition=pibu_el8
#SBATCH --array=0-1
#SBATCH --mail-user=przemyslaw.pilipczuk@students.unibe.ch
#SBATCH --mail-type=end,fail

RESULTDIR=/data/users/ppilipczuk/GenomeAndTransAss/results
BASEDIR=/data/users/ppilipczuk/GenomeAndTransAss

# Assemblies
FLYE="$RESULTDIR/flye/assembly.fasta"
HIFI="$RESULTDIR/hifiasm/assembly_primary_contig.fa"
LJA="$RESULTDIR/LJA/k501/disjointigs.fasta"

if [ $SLURM_ARRAY_TASK_ID -eq 0 ]; then
    echo "Running QUAST WITH reference"
    OUTDIR="$RESULTDIR/quast/ref"
    mkdir -p "$OUTDIR"
    apptainer exec --bind /data /containers/apptainer/quast_5.2.0.sif quast.py \
      "$FLYE" "$HIFI" "$LJA" \
      --labels "flye,hifi,lja" \
      --threads 16 \
      -o "$OUTDIR" \
      --eukaryote --large \
      --est-ref-size 135000000 \
      --features /data/courses/assembly-annotation-course/references/TAIR10_GFF3_genes.gff \
      --pacbio "$BASEDIR/reads.fastq.gz" \
      --no-sv \
      -R /data/courses/assembly-annotation-course/references/Arabidopsis_thaliana.TAIR10.dna.toplevel.fa
    echo "QUAST with REF done"
else
    echo "Running QUAST WITHOUT reference"
    OUTDIR="$RESULTDIR/quast/refless"
    mkdir -p "$OUTDIR"
    apptainer exec --bind /data /containers/apptainer/quast_5.2.0.sif quast.py \
      "$FLYE" "$HIFI" "$LJA" \
      --labels "flye,hifi,lja" \
      --threads 16 \
      -o "$OUTDIR" \
      --eukaryote --large \
      --est-ref-size 135000000 \
      --pacbio "$BASEDIR/reads.fastq.gz" \
      --no-sv
    echo "QUAST REFLESS done"
fi









##!/bin/bash
##SBATCH --time=48:00:00
##SBATCH --mem=64g
##SBATCH --cpus-per-task=16
##SBATCH --job-name=AssemblyQuast
##SBATCH --partition=pibu_el8
##SBATCH --mail-user=przemyslaw.pilipczuk@students.unibe.ch
##SBATCH --mail-type=end,fail
#
## Load required modules or apptainer
## module load Apptainer if needed
#
## Run QUAST with reference
#mkdir -p "$RESULTDIR/quast/ref"
#apptainer exec --bind /data /containers/apptainer/quast_5.2.0.sif quast.py \
#  "$RESULTDIR/flye/assembly.fasta" \
#  "$RESULTDIR/hifiasm/assembly_primary_contig.fa" \
#  "$RESULTDIR/LJA/k501/disjointigs.fasta" \
#  --labels "flye,hifi,lja" \
#  --threads 16 \
#  -o "$RESULTDIR/quast/ref" \
#  --eukaryote --large \
#  --est-ref-size 135000000 \
#  --features /data/courses/assembly-annotation-course/references/TAIR10_GFF3_genes.gff \
#  --pacbio "$BASEDIR/reads.fastq.gz" \
#  --no-sv \
#  -R /data/courses/assembly-annotation-course/references/Arabidopsis_thaliana.TAIR10.dna.toplevel.fa
#
#echo "QUAST with REF DONE"
#
## Run QUAST without reference
#mkdir -p "$RESULTDIR/quast/refless"
#apptainer exec --bind /data /containers/apptainer/quast_5.2.0.sif quast.py \
#  "$RESULTDIR/flye/assembly.fasta" \
#  "$RESULTDIR/hifiasm/assembly_primary_contig.fa" \
#  "$RESULTDIR/LJA/k501/disjointigs.fasta" \
#  --labels "flye,hifi,lja" \
#  --threads 16 \
#  -o "$RESULTDIR/quast/refless" \
#  --eukaryote --large \
#  --est-ref-size 135000000 \
#  --pacbio "$BASEDIR/reads.fastq.gz" \
#  --no-sv
#
#echo "QUAST REFLESS DONE"
#