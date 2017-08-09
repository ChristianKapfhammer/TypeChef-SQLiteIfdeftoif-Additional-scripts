#/bin/bash

if [ ! -d /scratch/kapfhamm/logs/sqlite/update ]; then
    mkdir /scratch/kapfhamm/logs/sqlite/update
fi

for i in `seq -s " " -f %02g 1 17`; do
    sbatch -A spl --cpus-per-task=1 -p chimaira --time=00:25:00 -o /scratch/kapfhamm/logs/sqlite/update/chimaira_${i}.txt -w chimaira${i} update_sqlite.sh
done
