#!/bin/bash

homeDir=/scratch/kapfhamm/execcode_code
localDir=/local/kapfhamm/sqlite
sqliteDir=$localDir/TypeChef-SQLiteIfdeftoif
herculesDir=$localDir/Hercules

rm $herculesDir/granularity_config.txt
cp $homeDir/granularity_config.txt $herculesDir/granularity_config.txt

rm $herculesDir/predefined_function_scores.txt
cp $homeDir/predefined_function_scores.txt $herculesDir/predefined_function_scores.txt

rm $herculesDir/function_offsets.txt
cp $homeDir/function_offsets.txt $herculesDir/function_offsets.txt

if [ $USER == "flo" ]; then
    homeDir=/home/flo # th3_generated_performance here; contains the generated SQLite ifdeftoif files
    localDir=/home/flo/TypeChef	# TH3 here
    sqliteDir=$localDir/TypeChef-SQLiteIfdeftoif 
    herculesDir=$localDir/Hercules
fi
if [ $USER == "rhein" ]; then
    homeDir=/local/ifdeftoif/ # th3_generated_performance here; contains the generated SQLite ifdeftoif files
    localDir=/local/ifdeftoif/	# TH3 here
    sqliteDir=/local/ifdeftoif/TypeChef-SQLiteIfdeftoif
    herculesDir=/local/ifdeftoif/Hercules
fi

TESTDIRS=$(find $localDir/TH3 -name '*test' ! -path "$localDir/TH3/stress/*" -printf '%h\n' | sort -u | wc -l)
CFGFILES=$(find $localDir/TH3/cfg/ -name "*.cfg" ! -name "cG.cfg" | wc -l)
TOTAL=$(( $TESTDIRS * $CFGFILES ))

TESTDIRNO=$(( ($1 / $CFGFILES) + 1 ))
TH3CFGNO=$(( ($1 % $CFGFILES) + 1 ))

if [ $1 -lt $TOTAL ]; then
    cd $homeDir
    mkdir th3_generated_performance 2>/dev/null
    cd th3_generated_performance
    rm -rf tmp_$1
    mkdir tmp_$1
    cd tmp_$1
    workingDir=$homeDir/th3_generated_performance/tmp_$1

    # find $1'th sub directory containing .test files, excluding stress folder
    TESTDIR=$(find $localDir/TH3 -name '*test' ! -path "./TH3/stress/*" -printf '%h\n' | sort -u | head -n $TESTDIRNO | tail -n 1)
    TESTDIRBASE=$(basename $TESTDIR)

    # find $3'th .cfg
    TH3CFG=$(find $localDir/TH3/cfg/ -name "*.cfg" ! -name "cG.cfg" | sort | head -n $TH3CFGNO | tail -n 1)
    TH3CFGBASE=$(basename $TH3CFG)

    echo "Generating ifdeftoif test file for testdir #$TESTDIRNO $TESTDIRBASE and th3 config #$TH3CFGNO $TH3CFGBASE"
    cd $localDir/TH3
    # Ignore ctime03.test since it features a very large struct loaded with 100 different #ifdefs & #elses
    # Ignore date2.test since it returns the systems local time; this makes string differences in test results impossible
    TESTFILES=$(find $TESTDIR -name "*.test" ! -name "ctime03.test" ! -name "date2.test" | sort)
    # Use whitelist for tests if it exists
    if [ -f ../TypeChef-SQLiteIfdeftoif/th3_whitelist/$1.txt ]; then
        source ../TypeChef-SQLiteIfdeftoif/th3_whitelist/$1.txt
        TESTFILES=${Whitelist[@]}
    fi
    ./mkth3.tcl $TESTFILES "$TH3CFG" > $workingDir/th3_generated_test.c
    cd $workingDir

    # Copy files used for compilation into temporary directory
    cp $sqliteDir/id2i_optionstruct.h .
    cp $sqliteDir/sqlite3_modified.c .
    cp $sqliteDir/sqlite3.h .
    cp $sqliteDir/ifdeftoif_helpers/custom_limitations.txt sqlite3_modified.pc
    echo -e "\n" >> sqlite3_modified.c
    cat th3_generated_test.c >> sqlite3_modified.c

    #insert /* Alex: added initialization of our version of the azCompileOpt array */ init_azCompileOpt();
    sed -i 's/int main(int argc, char \*\*argv){/int main(int argc, char \*\*argv){\/* Alex: added initialization of our version of the azCompileOpt array *\/\n  init_azCompileOpt()\;/' \
        sqlite3_modified.c
    #better never touch this sed again

    # start ifdeftoif
    cd $herculesDir
    ./ifdeftoif.sh  \
        --bdd --performance --debugInterface\
        -I /usr/local/include \
        -I /usr/lib/gcc/x86_64-linux-gnu/4.8/include-fixed \
        -I /usr/lib/gcc/x86_64-linux-gnu/4.8/include \
        -I /usr/include/x86_64-linux-gnu \
        -I /usr/include \
        -I /usr/lib/gcc/x86_64-linux-gnu/5/include-fixed \
        -I /usr/lib/gcc/x86_64-linux-gnu/5/include \
        --platfromHeader $sqliteDir/platform.h \
        --openFeat $sqliteDir/openfeatures.txt \
        --featureModelFExpr $sqliteDir/fm.txt \
        --smallFeatureModelDimacs $sqliteDir/sqlite.dimacs \
        --include $sqliteDir/partial_configuration.h \
        --ifdeftoif --simpleSwitch \
        -U WIN32 -U _WIN32 \
        -U __CYGWIN__ -U __MINGW32__ \
        -U SQLITE_HAVE_ISNAN \
        --granularexeccode 2 \
        $workingDir/sqlite3_modified.c > $workingDir/../log_$1.txt 2>&1
    cd $workingDir

# --granularexeccode 1 \

    # Change optionstruct path in the first line of the transformed file
    sed -i 's/#include ".*id2i_optionstruct\.h"/#include "id2i_optionstruct.h"/' sqlite3_modified_performance.c
    mv sqlite3_modified_performance.c ../sqlite3_performance_$1.c
    mv map.csv ../map_$1.csv
    cd ..
    rm -rf tmp_$1
fi
