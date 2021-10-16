#!/bin/bash
set -e

BENCHMARKDIR=~/nvm-benchmarks/redis
cp $BENCHMARKDIR/run.sh $BENCHMARKDIR/run2.sh
sed -i '6s/export PMCheck.*/export PMCheck="-d.\/redis.pm -x1 -p1 -y -e -r2000"/' $BENCHMARKDIR/run2.sh
# Run pre-crash client
./testcase/redistestcase.sh 1 | $BENCHMARKDIR/run2.sh $BENCHMARKDIR/src/redis-cli

read  -n 1 -p "Press any keys to start Post-rash client.." mainmenuinput

# Run post-crash client
./testcase/redistestcase.sh 0 | $BENCHMARKDIR/run2.sh $BENCHMARKDIR/src/redis-cli
