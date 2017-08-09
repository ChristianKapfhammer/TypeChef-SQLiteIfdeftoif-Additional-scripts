#!/bin/bash

scratchDir=/scratch/kapfhamm

if [ ! -d $scratchDir/th3_generated_performance ]; then
    mkdir $scratchDir/th3_generated_performance
fi

if [ ! -z "$1" ]
then
    if [ "$1" == "BinScore" ]
    then
        rm $scratchDir/th3_generated_performance/*
        cp $scratchDir/binscore_code/th3_generated_performance/* $scratchDir/th3_generated_performance/
    elif [ "$1" == "Statements" ]
    then
        rm $scratchDir/th3_generated_performance/*
        cp $scratchDir/execcode_code/th3_generated_performance/* $scratchDir/th3_generated_performance/
    elif [ "$1" == "PerfFilter" ]
    then
        rm $scratchDir/th3_generated_performance/*
        cp $scratchDir/perffilter_code/th3_generated_performance/* $scratchDir/th3_generated_performance/
    else
        echo "No valid parameter. Allowed parameters are: BinScore, Statements, PerfFilter"
    fi
else
    echo "No valid parameter. Allowed parameters are: BinScore, Statements, PerfFilter"
fi

for i in `seq -s " " 1 3`; do
    sbatch sqlite_performance_allyes.sh $i
    sbatch sqlite_performance_pairwise.sh $i
    sbatch sqlite_performance_featurewise.sh $i
    sbatch sqlite_performance_random.sh $i

    sbatch sqlite_performance_pairwise_variant.sh $i
    sbatch sqlite_performance_featurewise_variant.sh $i
    sbatch sqlite_performance_random_variant.sh $i
done
