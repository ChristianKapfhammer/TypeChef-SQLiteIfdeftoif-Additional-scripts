#!/bin/bash

taskName="hercules-sqlite-update"
homeDir=/local/kapfhamm
sqliteDir=/local/kapfhamm/sqlite

if [ ! -d $sqliteDir ]; then
    mkdir $sqliteDir
fi

# Call this script as follows:
# chimaira_update.sh
if [ -d $sqliteDir ]; then
    cd $sqliteDir

    # get TH3
    rm -rf TH3/
    cp -r /scratch/kapfhamm/TH3 .

    # Initialize

    echo =================================================================
    echo % TYPECHEF UPDATE\(s\)
    echo =================================================================

    if [ ! -d TypeChef ]; then
        # get TypeChef
        git clone https://github.com/aJanker/TypeChef.git
        cd TypeChef
        git checkout master
        java -Dsbt.boot.directory=$homeDir -Dsbt.ivy.home=$homeDir -Divy.home=$homeDir -jar sbt-launch.jar publish-local
    else
        # update TypeChef
        cd TypeChef
            pull=$(git pull 2>&1)
        if [ $pull != "Already up-to-date." ] && [ $pull != *"fatal:"* ]; then
            java -Dsbt.boot.directory=$homeDir -Dsbt.ivy.home=$homeDir -Divy.home=$homeDir -jar sbt-launch.jar publish-local
        else
            echo $pull
            echo "Skipping TypeChef ./publish.sh"
        fi
        cd $OLDPWD
    fi

    cd $sqliteDir

    echo =================================================================
    echo % HERCULES UPDATE\(s\)
    echo =================================================================

    if [ ! -d Hercules ]; then
        # get Hercules
        git clone https://github.com/ChristianKapfhammer/Hercules.git
 #       git clone https://github.com/joliebig/Hercules.git
        cd Hercules
        java -Dsbt.boot.directory=$homeDir -Dsbt.ivy.home=$homeDir -Divy.home=$homeDir -jar sbt-launch.jar compile copy-resources mkrun
    else
        # update Hercules
        cd Hercules
        pull=$(git pull 2>&1)
        java -Dsbt.boot.directory=$homeDir -Dsbt.ivy.home=$homeDir -Divy.home=$homeDir -jar sbt-launch.jar compile copy-resources mkrun
        if [ $pull != "Already up-to-date." ] && [ $pull != *"fatal:"* ]; then
            java -Dsbt.boot.directory=$homeDir -Dsbt.ivy.home=$homeDir -Divy.home=$homeDir -jar sbt-launch.jar compile copy-resources mkrun
        else
            echo $pull
            echo "Skipping Hercules ./mkrun.sh"
        fi
        cd $OLDPWD
    fi

    echo =================================================================
    echo % SQLITE UPDATE\(s\)
    echo =================================================================

    cd $sqliteDir

    if [ ! -d TypeChef-SQLiteIfdeftoif ]; then
        # get SQLITE
        git clone https://github.com/fgarbe/TypeChef-SQLiteIfdeftoif
    else
        # update SQLITE
        cd TypeChef-SQLiteIfdeftoif/ && git pull && cd $OLDPWD
    fi

    cd $sqliteDir/TypeChef-SQLiteIfdeftoif/

    rm sqlite3_modified.c
    cp /scratch/kapfhamm/sqlite3_modified.c .
      
else
    echo "Wrong machine? Script cancelled"
fi
