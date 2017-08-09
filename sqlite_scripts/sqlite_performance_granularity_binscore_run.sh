#!/bin/bash
#SBATCH -o /scratch/kapfhamm/logs/sqlite/performance_granularity/perf-%a.txt
#SBATCH --job-name=sqlite-th3
#SBATCH -p anywhere
#SBATCH -p chimaira
#SBATCH -A spl
#SBATCH --get-user-env
#SBATCH --ntasks 1
#SBATCH --mem=13000
#SBATCH --array=0-299

#SBATCH --time=03:00:00 # 1h30m max

#SBATCH --cpus-per-task 1   # 1 for easier apps experiment

##SBATCH --cpus-per-task 10     #set to 10 for full chimaira core per apk (60 GB ram)
##SBATCH --exclusive        #remove for easier apps experiment

# 25 test cfgs; 12 test folders
# 25*12 = 300 different test scenarios

taskName="hercules-sqlite-th3"
localDir=/local/kapfhamm/sqlite
resultDir=/scratch/kapfhamm/sqlite
lastJobNo=300

# Call this script as follows:
# sbatch sqlite_performance_granularity.sh

echo =================================================================
echo % HERCULES TH3 GENERATION GRANULARITY\(s\)
echo % Task ID: ${SLURM_ARRAY_TASK_ID}
echo % JOB ID: ${SLURM_JOBID}
echo =================================================================

rm $localDir/TypeChef-SQLiteIfdeftoif/sqlite_performance_granularity_binscore.sh
cp sqlite_performance_granularity_binscore.sh $localDir/TypeChef-SQLiteIfdeftoif/

cd $localDir
cd TypeChef-SQLiteIfdeftoif
# Use java 8
export PATH=/usr/lib/jvm/jdk-8-oracle-x64/bin/:$PATH
./sqlite_performance_granularity_binscore.sh ${SLURM_ARRAY_TASK_ID}
