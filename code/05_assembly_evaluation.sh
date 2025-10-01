#!/bin/bash

#SBATCH --time=15:00:00
#SBATCH --mem=64g
#SBATCH --cpus-per-task=16
#SBATCH --job-name=AssemblyEval
#SBATCH --partition=pibu_el8
#SBATCH --mail-user=przemyslaw.pilipczuk@students.unibe.ch
#SBATCH --mail-type=end,fail

# QUAST

mkdir -p "$RESULTDIR/quast/ref"
apptainer exec \
  --bind /data \
  /containers/apptainer/quast_5.2.0.sif \
  quast.py \
    "$RESULTDIR/flye/assembly.fasta" \
    "$RESULTDIR/hifiasm/assembly_primary_contig.fa"  \
    "$RESULTDIR/LJA/k501/disjointings.fasta" \
    --labels "flye,hifi,lja" \
    --threads 16 \
    -o "$RESULTDIR/quast/ref" \
    --eukaryote --large --pacbio \
    --est-ref-size 135000000 \
    --features /data/courses/assembly-annotation-course/references/TAIR10_GFF3_genes.gff \
    --no-sv \
    -R /data/courses/assembly-annotation-course/references/Arabidopsis_thaliana.TAIR10.dna.toplevel.fa

echo "Quast w/ REF DONE"
mkdir -p "$RESULTDIR/quast/refless"
apptainer exec \
  --bind /data \
  /containers/apptainer/quast_5.2.0.sif \
  quast.py \
    "$RESULTDIR/flye/assembly.fasta" \
    "$RESULTDIR/hifiasm/assembly_primary_contig.fa"  \
    "$RESULTDIR/LJA/k501/disjointings.fasta" \
    --labels "flye,hifi,lja" \
    --threads 16 \
    -o "$RESULTDIR/quast/refless" \
    --eukaryote --large --pacbio \
    --est-ref-size 135000000 \
    --no-sv 

echo "Quast REFLESS DONE"

mkdir -p "$RESULTDIR/busco"
# flye assembly
OD="$RESULTDIR/busco/flye"
mkdir -p "$OD"
apptainer exec \
  --bind /data \
  /containers/apptainer/busco-v5.6.1_cv1.sif \
  busco -i "$RESULTDIR/flye/assembly.fasta" -c 16 -o "$OD" -m genome -l brassicales_odb10

echo BUSCO - FLYE DONE

OD="$RESULTDIR/busco/hifi"
mkdir -p "$OD"
apptainer exec \
  --bind /data \
  /containers/apptainer/busco-v5.6.1_cv1.sif \
  busco -i "$RESULTDIR/hifiasm/assembly_primary_contig.fa" -c 16 -o "$OD" -m genome -l brassicales_odb10

echo BUSCO - HIFI DONE

OD="$RESULTDIR/busco/lja"
mkdir -p "$OD"
apptainer exec \
  --bind /data \
  /containers/apptainer/busco-v5.6.1_cv1.sif \
  busco -i "$RESULTDIR/LJA/k501/disjointings.fasta" -c 16 -o "$OD" -m genome -l brassicales_odb10

echo BUSCO - LJA DONE

OD="$RESULTDIR/busco/trinity"
mkdir -p "$OD"
apptainer exec \
  --bind /data \
  /containers/apptainer/busco-v5.6.1_cv1.sif \
  busco -i "$RESULTDIR/Trinity/*.fasta" -c 16 -o "$OD" -m transcriptome -l brassicales_odb10

echo BUSCO - TRINITY DONE


OD="$RESULTDIR/mercury"
mkdir -p "$OD"

# NO MERCURY AT CURRENT POINT
