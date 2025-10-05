#!/bin/bash
#SBATCH --time=24:00:00
#SBATCH --mem=32g
#SBATCH --cpus-per-task=8
#SBATCH --job-name=Mummer
#SBATCH --partition=pibu_el8
#SBATCH --mail-user=przemyslaw.pilipczuk@students.unibe.ch
#SBATCH --mail-type=end,fail

RESULTDIR=/data/users/ppilipczuk/GenomeAndTransAss/results/mummer
REF=/data/courses/assembly-annotation-course/references/Arabidopsis_thaliana.TAIR10.dna.toplevel.fa

FLYE=/data/users/ppilipczuk/GenomeAndTransAss/results/flye/assembly.fasta
HIFI=/data/users/ppilipczuk/GenomeAndTransAss/results/hifiasm/assembly_primary_contig.fa
LJA=/data/users/ppilipczuk/GenomeAndTransAss/results/LJA/k501/disjointigs.fasta

mkdir -p $RESULTDIR

# ------------------------
# 1. Against reference
# ------------------------
for ASM in flye hifi lja; do
    case $ASM in
        flye) ASMFILE=$FLYE ;;
        hifi) ASMFILE=$HIFI ;;
        lja)  ASMFILE=$LJA ;;
    esac
    
    OUTPREFIX=$RESULTDIR/${ASM}_vs_ref
    echo "Running nucmer: $ASM vs reference"
    
    apptainer exec --bind /data /containers/apptainer/mummer4_gnuplot.sif \
      nucmer --prefix=$OUTPREFIX --breaklen 1000 --mincluster 1000 $REF $ASMFILE
    
    echo "Plotting with mummerplot"
    apptainer exec --bind /data /containers/apptainer/mummer4_gnuplot.sif \
      mummerplot -R $REF -Q $ASMFILE --filter -t png --large --layout --fat \
      -p $OUTPREFIX $OUTPREFIX.delta
done

# ------------------------
# 2. Assemblies vs each other
# ------------------------
PAIRS=("flye:hifi" "flye:lja" "hifi:lja")

for P in "${PAIRS[@]}"; do
    A=${P%:*}
    B=${P#*:}
    
    case $A in
        flye) AFILE=$FLYE ;;
        hifi) AFILE=$HIFI ;;
        lja)  AFILE=$LJA ;;
    esac
    case $B in
        flye) BFILE=$FLYE ;;
        hifi) BFILE=$HIFI ;;
        lja)  BFILE=$LJA ;;
    esac

    OUTPREFIX=$RESULTDIR/${A}_vs_${B}
    echo "Running nucmer: $A vs $B"
    
    apptainer exec --bind /data /containers/apptainer/mummer4_gnuplot.sif \
      nucmer --prefix=$OUTPREFIX --breaklen 1000 --mincluster 1000 $AFILE $BFILE
    
    echo "Plotting with mummerplot"
    apptainer exec --bind /data /containers/apptainer/mummer4_gnuplot.sif \
      mummerplot -R $AFILE -Q $BFILE --filter -t png --large --layout --fat \
      -p $OUTPREFIX $OUTPREFIX.delta
done

echo "MUMmer comparisons finished."
