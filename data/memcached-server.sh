#!/bin/bash
set -e
######################################## Defining variables
BENCHMARKDIR=~/nvm-benchmarks/memcached
RESULTDIR=~/results
BUGDIR=$RESULTDIR/memcached
LOGDIR=$BUGDIR/logs
PMRACEDIR=~/pmcheck

## Modifying PMRace to print Warning due to ungracefull shutdown by memcached
cd $PMRACEDIR
sed -i '331i	complete=true;' Model/model.cc
make
cd

######################################### Running Jaaru to find bugs
cd $BENCHMARKDIR
mkdir -p $RESULTDIR
rm -rf $BUGDIR
mkdir $BUGDIR
mkdir $LOGDIR

# Cleaning Up previous data
rm -f foo

# Run Server
sed -i '6s/export PMCheck.*/export PMCheck="-dfoo -x2 -p1 -y -e -r2000"/' run.sh
BENCHMARKNAME=memcached-pmem
echo "Running $BENCHMARKNAME ..."
TREELOG=$LOGDIR/$BENCHMARKNAME-org.log
time ./run.sh ./memcached | tee $TREELOG
grep 'ERROR' $TREELOG | grep -v "uninstrumented" &> $BUGDIR/$BENCHMARKNAME-races.log

## Reverting changes in PMRace
cd $PMRACEDIR
git checkout -- Model/model.cc
make
cd
