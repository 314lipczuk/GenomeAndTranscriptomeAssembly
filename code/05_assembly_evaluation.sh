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
     "$RESULTDIR/LJA/k501/disjointigs.fasta" \
    --labels "flye,hifi,lja" \
    --threads 16 \
    -o "$RESULTDIR/quast/ref" \
    --eukaryote --large  \
    --est-ref-size 135000000 \
    --features /data/courses/assembly-annotation-course/references/TAIR10_GFF3_genes.gff \
    --pacbio "$BASEDIR/reads.fastq.gz" \
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
     "$RESULTDIR/LJA/k501/disjointigs.fasta" \
     --pacbio "$BASEDIR/reads.fastq.gz" \
    --labels "flye,hifi,lja" \
    --threads 16 \
    -o "$RESULTDIR/quast/refless" \
    --eukaryote --large \
    --est-ref-size 135000000 \
    --no-sv 

echo "Quast REFLESS DONE"

mkdir -p "$RESULTDIR/busco"
# flye assembly

#apptainer exec \
#  --bind /data \
#  /containers/apptainer/busco -f-v5.6.1_cv1.sif \

module load BUSCO/5.4.2-foss-2021a

busco -f -i "$RESULTDIR/flye/assembly.fasta" -c 16 --out_path "$RESULTDIR/busco" -o "flye"  -m genome -l brassicales_odb10

echo busco - FLYE DONE

OD="$RESULTDIR/busco/hifi"
mkdir -p "$OD"
#apptainer exec \
#  --bind /data \
#  /containers/apptainer/busco -f-v5.6.1_cv1.sif \
busco -f -i "$RESULTDIR/hifiasm/assembly_primary_contig.fa" -c 16 --out_path "$RESULTDIR/busco" -o "hifi" -m genome -l brassicales_odb10

echo busco - HIFI DONE

OD="$RESULTDIR/busco/lja"
mkdir -p "$OD"
#apptainer exec \
#  --bind /data \
#  /containers/apptainer/busco -f-v5.6.1_cv1.sif \
busco -f -i "$RESULTDIR/LJA/k501/disjointigs.fasta" -c 16 --out_path "$RESULTDIR/busco" -o "lja" -m genome -l brassicales_odb10

echo busco - LJA DONE

OD="$RESULTDIR/busco/trinity"
mkdir -p "$OD"
#apptainer exec \
#  --bind /data \
#  /containers/apptainer/busco -f-v5.6.1_cv1.sif \
busco -f -i "$RESULTDIR/Trinity.Trinity.fasta" -c 16 --out_path "$RESULTDIR/busco" -o "trinity" -m transcriptome -l brassicales_odb10

echo busco - TRINITY DONE

export MERQURY="/usr/local/share/merqury"

# HIFI

OD="$RESULTDIR/mercury/hifi"
mkdir -p "$OD"
apptainer exec \
  --bind /data \
  /containers/apptainer/meryl_1.4.1.sif \
  meryl k=23.3272 count "$RESULTDIR/hifiasm/assembly_primary_contig.fa" output "$OD/hifi.meryl"


apptainer exec \
  --bind /data \
  /containers/apptainer/merqury_1.3.sif  \
  $MERCURY/mercury.sh hifi.meryl output_hifi.meryl outfile
