#!/bin/bash
set -e
######################################## Defining variables
BENCHMARKDIR=~/nvm-benchmarks/redis/
RESULTDIR=~/results
BUGDIR=$RESULTDIR/redis
LOGDIR=$BUGDIR/logs
######################################### Running Jaaru to find bugs
cd $BENCHMARKDIR
mkdir -p $RESULTDIR
rm -rf $BUGDIR
mkdir $BUGDIR
mkdir $LOGDIR
# Cleaning up data from previous executions if exist
rm -f redis.pm
rm -f dump.rdb
# Run Server
sed -i '6s/export PMCheck.*/export PMCheck="-d.\/redis.pm -x2 -p1 -o2 -e -r2000"/' run.sh
BENCHMARKNAME=redis
echo "Running $BENCHMARKNAME ..."
TREELOG=$LOGDIR/$BENCHMARKNAME-org.log
time ./run.sh ./src/redis-server ./redis.conf | tee $TREELOG
grep 'ERROR' $TREELOG | grep -v "uninstrumented" &> $BUGDIR/$BENCHMARKNAME-races.log
