# Environment setup for the workshop pipeline
# - Defines base paths used by all other scripts
# - Source this file before running any step to ensure variables are set
#
# Variables:
# - BASEDIR: project root directory containing reads and subfolders
# - CODEDIR: path to scripts
# - DATADIR: path to data inputs (if used by steps)
# - LOGDIR: path to store SLURM/stdout logs (managed by run.sh)
# - RESULTDIR: path to store results of each step
#
export BASEDIR="/data/users/ppilipczuk/GenomeAndTransAss"
export CODEDIR="$BASEDIR/CODE"
export DATADIR="$BASEDIR/data"
export LOGDIR="$BASEDIR/logs"
export RESULTDIR="$BASEDIR/results"
echo "sourced config.sh"
