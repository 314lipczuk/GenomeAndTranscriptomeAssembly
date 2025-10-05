#!/bin/bash
#SBATCH --time=48:00:00
#SBATCH --mem=32g
#SBATCH --cpus-per-task=16
#SBATCH --job-name=AssemblyBusco
#SBATCH --partition=pibu_el8
#SBATCH --array=0-3
#SBATCH --mail-user=przemyslaw.pilipczuk@students.unibe.ch
#SBATCH --mail-type=end,fail

module load BUSCO/5.4.2-foss-2021a

# Define assemblies
ASSEMBLIES=(
  "$RESULTDIR/flye/assembly.fasta"
  "$RESULTDIR/hifiasm/assembly_primary_contig.fa"
  "$RESULTDIR/LJA/k501/disjointigs.fasta"
  "$RESULTDIR/Trinity.Trinity.fasta"
)

NAMES=("flye" "hifi" "lja" "trinity")
MODES=("genome" "genome" "genome" "transcriptome")

INPUT=${ASSEMBLIES[$SLURM_ARRAY_TASK_ID]}
NAME=${NAMES[$SLURM_ARRAY_TASK_ID]}
MODE=${MODES[$SLURM_ARRAY_TASK_ID]}

OUTDIR="$RESULTDIR/busco"
mkdir -p "$OUTDIR"

busco -f -i "$INPUT" -c 16 --out_path "$OUTDIR" -o "$NAME" -m "$MODE" -l brassicales_odb10

echo "BUSCO done for $NAME"
