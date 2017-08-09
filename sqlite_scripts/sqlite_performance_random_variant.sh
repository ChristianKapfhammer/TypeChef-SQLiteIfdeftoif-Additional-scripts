#!/bin/bash
#SBATCH -o /scratch/kapfhamm/logs/sqlite/performance_random_variant/var-rnd-%a.txt
#SBATCH --job-name=rnd-var-sqlite
#SBATCH -p chimaira
#SBATCH -A spl
#SBATCH --get-user-env
#SBATCH --ntasks 1
#SBATCH --mem=10000
#SBATCH --array=0-24,75-174,225-249

#SBATCH --time=24:00:00 # 4h max

#SBATCH --cpus-per-task 1   # 1 for easier apps experiment

##SBATCH --cpus-per-task 10     #set to 10 for full chimaira core per apk (60 GB ram)
#SBATCH --exclusive        #remove for easier apps experiment

# 25 sqlite cfgs; 26 test cfgs; 10 test folders
# 25*26*12 = 7800 different test scenarios

taskName="hercules-sqlite-perf-featurewise"
localDir=/local/kapfhamm/sqlite
resultDir=/scratch/kapfhamm/sqlite
lastJobNo=7799

# Call this script as follows:
# sbatch slurm_featurewise.sh

echo =================================================================
echo % HERCULES SQLITE FEATUREWISE\(s\)
echo % Task ID: ${SLURM_ARRAY_TASK_ID}
echo % JOB ID: ${SLURM_JOBID}
echo =================================================================

cd $localDir

cd TypeChef-SQLiteIfdeftoif
./performance_random_variant.sh ${SLURM_ARRAY_TASK_ID} $1
