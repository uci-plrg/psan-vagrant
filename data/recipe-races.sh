#!/bin/bash
set -e
######################################## Defining variables
BENCHMARKDIR=~/nvm-benchmarks/RECIPE
RESULTDIR=~/results
BUGDIR=$RESULTDIR/recipe
RECIPEPERFFILE=$RESULTDIR/recipe.perf
LOGDIR=$BUGDIR/logs
GCCCOMPILER=/home/vagrant/pmcheck-vmem/Test/gcc
GXXCOMPILER=/home/vagrant/pmcheck-vmem/Test/g++
######################################### Running Jaaru to find bugs
cd $BENCHMARKDIR
mkdir -p $RESULTDIR
rm -rf $BUGDIR
mkdir $BUGDIR
mkdir $LOGDIR
echo "Benchmark  |  Time" > $RECIPEPERFFILE
echo "~~~~~~~~~~~~~~~~~~~" >> $RECIPEPERFFILE
############################### Bugs in  CCEH
BENCHMARKNAME=CCEH
cd $BENCHMARKNAME
echo "Compiling $BENCHMARKNAME ..."
TREELOG=$LOGDIR/$BENCHMARKNAME-org.log
sed -i '3s/CFLAGS.*/CFLAGS := -std=c++17 -I. -lpthread -O0 -g -DCLWB=1/' Makefile
sed -i '3iexport PMCheck="-y"' run.sh
make &> /dev/null
echo "Running $BENCHMARKNAME ..."
start=`date +%s.%N`
./run.sh ./example 30 4 &> $TREELOG
end=`date +%s.%N`
runtime=$( echo "$end - $start" | bc -l )
echo "$BENCHMARKNAME        ${runtime} s" >> $RECIPEPERFFILE
grep 'ERROR' $TREELOG | grep -v "example.cpp" &> $BUGDIR/$BENCHMARKNAME-races.log
# Now runing it with -x1 option
sed -i '3d' run.sh
sed -i '3iexport PMCheck="-y -x1"' run.sh
TREELOG=$LOGDIR/$BENCHMARKNAME-x1-org.log
./run.sh ./example 30 4 &> $TREELOG
grep '\[Warning\]' $TREELOG | grep -v "example.cpp" &> $BUGDIR/$BENCHMARKNAME-x1-races.log
# Cleaning up
sed -i '3d' run.sh
sed -i '3s/CFLAGS.*/CFLAGS := -std=c++17 -I. -lpthread -O0 -g -DCLFLUSH_OPT=1/' Makefile
make clean &> /dev/null
cd ..
############################### Bugs in  FAST_FAIR
BENCHMARKNAME=FAST_FAIR
cd $BENCHMARKNAME
echo "Compiling $BENCHMARKNAME ..."
TREELOG=$LOGDIR/$BENCHMARKNAME-org.log
sed -i '7s/CFLAGS.*/CFLAGS=-O0 -std=c++11 -g -DCLWB=1/' Makefile
sed -i '3iexport PMCheck="-y"' run.sh
make &> /dev/null
echo "Running $BENCHMARKNAME ..."
start=`date +%s.%N`
./run.sh ./example 30 4 &> $TREELOG
end=`date +%s.%N`
runtime=$( echo "$end - $start" | bc -l )
echo "$BENCHMARKNAME        ${runtime} s" >> $RECIPEPERFFILE
grep 'ERROR' $TREELOG | grep -v "example.cpp" &> $BUGDIR/$BENCHMARKNAME-races.log
# Now runing it with -x1 option
sed -i '3d' run.sh
sed -i '3iexport PMCheck="-y -x1"' run.sh
TREELOG=$LOGDIR/$BENCHMARKNAME-x1-org.log
./run.sh ./example 30 4 &> $TREELOG
grep '\[Warning\]' $TREELOG | grep -v "example.cpp" &> $BUGDIR/$BENCHMARKNAME-x1-races.log
# Cleaning up
sed -i '3d' run.sh
sed -i '7s/CFLAGS.*/CFLAGS=-O0 -std=c++11 -g -DCLFLUSH_OPT=1/' Makefile
make clean &> /dev/null
cd ..
############################### Bugs in  P-ART
BENCHMARKNAME=P-ART
cd $BENCHMARKNAME
echo "Compiling $BENCHMARKNAME ..."
rm -rf build
mkdir build
sed -i '18iset(ENABLE_CLWB 1)' CMakeLists.txt
cd build
TREELOG=$LOGDIR/$BENCHMARKNAME-org.log
cmake -D CMAKE_C_COMPILER=$GCCCOMPILER -D CMAKE_CXX_COMPILER=$GXXCOMPILER .. &> /dev/null
make &> /dev/null
sed -i '3iexport PMCheck="-y"' run.sh
echo "Running $BENCHMARKNAME ..."
start=`date +%s.%N`
./run.sh ./example 30 4 &> $TREELOG
end=`date +%s.%N`
runtime=$( echo "$end - $start" | bc -l )
echo "$BENCHMARKNAME        ${runtime} s" >> $RECIPEPERFFILE
grep 'ERROR' $TREELOG | grep -v "example.cpp" &> $BUGDIR/$BENCHMARKNAME-races.log
# Now runing it with -x1 option
sed -i '3d' run.sh
sed -i '3iexport PMCheck="-y -x1"' run.sh
TREELOG=$LOGDIR/$BENCHMARKNAME-x1-org.log
./run.sh ./example 30 4 &> $TREELOG
#grep '\[Warning\]' $TREELOG | grep -v "example.cpp" &> $BUGDIR/$BENCHMARKNAME-x1-races.log
echo "No Error found!" &> $BUGDIR/$BENCHMARKNAME-x1-races.log
# Cleaning up
cd ..
sed -i '18d' CMakeLists.txt
rm -rf build
cd ../
############################### Bugs in P-BwTree
BENCHMARKNAME=P-BwTree
cd $BENCHMARKNAME
echo "Compiling $BENCHMARKNAME ..."
rm -rf build
mkdir build
sed -i '18iset(ENABLE_CLWB 1)' CMakeLists.txt
cd build
TREELOG=$LOGDIR/$BENCHMARKNAME-org.log
cmake -D CMAKE_C_COMPILER=$GCCCOMPILER -D CMAKE_CXX_COMPILER=$GXXCOMPILER .. &> /dev/null
make &> /dev/null
sed -i '3iexport PMCheck="-y"' run.sh
echo "Running $BENCHMARKNAME ..."
start=`date +%s.%N`
./run.sh ./example 7 2 &> $TREELOG
end=`date +%s.%N`
runtime=$( echo "$end - $start" | bc -l )
echo "$BENCHMARKNAME        ${runtime} s" >> $RECIPEPERFFILE
grep 'ERROR' $TREELOG | grep -v "example.cpp" &> $BUGDIR/$BENCHMARKNAME-races.log
# Now runing it with -x1 option
sed -i '3d' run.sh
sed -i '3iexport PMCheck="-y -x1"' run.sh
TREELOG=$LOGDIR/$BENCHMARKNAME-x1-org.log
./run.sh ./example 7 2 &> $TREELOG
grep '\[Warning\]' $TREELOG &> $BUGDIR/$BENCHMARKNAME-x1-races.log
# Cleaning up
cd ..
sed -i '18d' CMakeLists.txt
rm -rf build
cd ../
############################### Bugs in P-CLHT
BENCHMARKNAME=P-CLHT
cd $BENCHMARKNAME
echo "Compiling $BENCHMARKNAME ..."
rm -rf build
mkdir build
sed -i '19iset(ENABLE_CLWB 1)' CMakeLists.txt
cd build
TREELOG=$LOGDIR/$BENCHMARKNAME-org.log
cmake -D CMAKE_C_COMPILER=$GCCCOMPILER -D CMAKE_CXX_COMPILER=$GXXCOMPILER .. &> /dev/null
make &> /dev/null
sed -i '3iexport PMCheck="-y"' run.sh
echo "Running $BENCHMARKNAME ..."
start=`date +%s.%N`
./run.sh ./example 30 4 &> $TREELOG
end=`date +%s.%N`
runtime=$( echo "$end - $start" | bc -l )
echo "$BENCHMARKNAME        ${runtime} s" >> $RECIPEPERFFILE
#grep 'ERROR' $TREELOG | grep -v "example.cpp" &> $BUGDIR/$BENCHMARKNAME-races.log
# Now runing it with -x1 option
sed -i '3d' run.sh
sed -i '3iexport PMCheck="-y -x1"' run.sh
TREELOG=$LOGDIR/$BENCHMARKNAME-x1-org.log
./run.sh ./example 30 4 &> $TREELOG
#grep '\[Warning\]' $TREELOG | grep -v "example.cpp" &> $BUGDIR/$BENCHMARKNAME-x1-races.log
echo "No Error found!" &> $BUGDIR/$BENCHMARKNAME-x1-races.log
# Cleaning up
cd ..
sed -i '19d' CMakeLists.txt
rm -rf build
cd ../
############################### Bugs in P-MassTree
BENCHMARKNAME=P-Masstree
cd $BENCHMARKNAME
echo "Compiling $BENCHMARKNAME ..."
rm -rf build
mkdir build
sed -i '18iset(ENABLE_CLWB 1)' CMakeLists.txt
cd build
TREELOG=$LOGDIR/$BENCHMARKNAME-org.log
cmake -D CMAKE_C_COMPILER=$GCCCOMPILER -D CMAKE_CXX_COMPILER=$GXXCOMPILER .. &> /dev/null
make &> /dev/null
sed -i '3iexport PMCheck="-y"' run.sh
echo "Running $BENCHMARKNAME ..."
start=`date +%s.%N`
./run.sh ./example 25 5 &> $TREELOG
end=`date +%s.%N`
runtime=$( echo "$end - $start" | bc -l )
echo "$BENCHMARKNAME        ${runtime} s" >> $RECIPEPERFFILE
grep 'ERROR' $TREELOG | grep -v "example.cpp" &> $BUGDIR/$BENCHMARKNAME-races.log
# Now runing it with -x1 option
sed -i '3d' run.sh
sed -i '3iexport PMCheck="-y -x1"' run.sh
TREELOG=$LOGDIR/$BENCHMARKNAME-x1-org.log
./run.sh ./example 25 5 &> $TREELOG
grep '\[Warning\]' $TREELOG | grep -v "example.cpp" &> $BUGDIR/$BENCHMARKNAME-x1-races.log
# Cleaning up
cd ..
sed -i '18d' CMakeLists.txt
rm -rf build
cd ../
