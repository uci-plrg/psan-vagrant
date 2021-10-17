#!/bin/bash
#set -e

function setup_result_dir {
	cd ~/nvm-benchmarks/RECIPE
	RESULTDIR=~/results
	mkdir -p $RESULTDIR
	BUGDIR=$RESULTDIR/recipe-jaaru-bugs
	rm -rf $BUGDIR
	mkdir $BUGDIR
}

function cceh_bug_1 {
	sed -i '178d' src/CCEH_LSB.cpp
	make BUGFLAG=-DVERIFYFIX=0 &> /dev/null
	sed -i '3iexport PMCheck="-f11 -o2 -p1"' run.sh
	timeout 30 ./run.sh ./example 2 1 >> $BUGDIR/CCEH-bug-1.log
	if [ $? -eq 124 ]; then
	    echo "ERROR: The test case terminated by hitting the timeout." >> $BUGDIR/CCEH-bug-1.log
	fi
	make clean &> /dev/null
	git checkout -- src/CCEH_LSB.cpp
	git checkout -- run.sh
}

function cceh_bug_2 {
	sed -i '179d' src/CCEH_LSB.cpp
	make BUGFLAG=-DVERIFYFIX=0 &> /dev/null
	sed -i '3iexport PMCheck="-f11 -o2 -p1"' run.sh
	timeout 30 ./run.sh ./example 2 1 >> $BUGDIR/CCEH-bug-2.log
	make clean &> /dev/null
        git checkout -- src/CCEH_LSB.cpp
        git checkout -- run.sh
}

function cceh_bug_3 {
	sed -i '184d' src/CCEH_LSB.cpp
	make BUGFLAG=-DVERIFYFIX=0 &> /dev/null
	sed -i '3iexport PMCheck="-f11 -o2 -p1"' run.sh
	timeout 30 ./run.sh ./example 2 1 >> $BUGDIR/CCEH-bug-3.log
	make clean &> /dev/null
        git checkout -- src/CCEH_LSB.cpp
        git checkout -- run.sh
}

function cceh_bugs {
	cd CCEH
	sed -i "3iBUGFLAG=''" Makefile
	sed -i '4s/$/ $(BUGFLAG)/' Makefile
	make clean
	
	cceh_bug_1
	cceh_bug_2
	cceh_bug_3

	git checkout -- Makefile
	sed -i 's/CXX := \/.*/CXX := ~\/pmcheck-vmem\/Test\/g++/g' Makefile
	cd ..
}

function fast_fair_bug_1 {
	sed -i '1859d' btree.h
	make BUGFLAG=-DVERIFYFIX=0 &> /dev/null
	sed -i '3iexport PMCheck="-f11 -o2 -p1"' run.sh
	timeout 10 ./run.sh ./example 10 2 &>> $BUGDIR/FAST_FAIR-bug-1.log
	make clean &> /dev/null
	git checkout -- btree.h
        git checkout -- run.sh
}

function fast_fair_bug_2 {
	sed -i '1863d' btree.h
	make BUGFLAG=-DVERIFYFIX=0 &> /dev/null
	sed -i '3iexport PMCheck="-f11 -o2 -p1"' run.sh
	timeout 10 ./run.sh ./example 2 2 >> $BUGDIR/FAST_FAIR-bug-2.log
	make clean &> /dev/null
        git checkout -- btree.h
        git checkout -- run.sh
}

function fast_fair_bugs {
	cd FAST_FAIR
	sed -i "3iBUGFLAG=''" Makefile
	sed -i '8s/$/ $(BUGFLAG)/' Makefile
	
	fast_fair_bug_1
	fast_fair_bug_2

	git checkout -- Makefile
	sed -i 's/CXX=.*/CXX=~\/pmcheck-vmem\/Test\/g++/g' Makefile
	cd ..
}

function p_art_bug_1 {
	sed -i '87d' ../Epoche.h
	sed -i '9d' ../Epoche.h
	make -j &> /dev/null
	sed -i '3iexport PMCheck="-f11 -o2 -p1"' run.sh
	timeout 10 ./run.sh ./example 9 5 &> $BUGDIR/P-ART-1.log
	make clean &> /dev/null
	sed -i '3d' run.sh
	git checkout -- ../Epoche.h
}

function p_art_bug_2 {
	sed -i '26d' ../Tree.cpp
	sed -i '9d' ../Epoche.h
	make -j &> /dev/null
	sed -i '3iexport PMCheck="-f11 -o2 -p1"' run.sh
	timeout 10 ./run.sh ./example 2 2 &> $BUGDIR/P-ART-2.log
	make clean &> /dev/null
        sed -i '3d' run.sh
	git checkout -- ../Epoche.h
	git checkout -- ../Tree.cpp
}

function p_art_bug_3 {
	sed -i '43d' ../example.cpp
	sed -i '9d' ../Epoche.h
	make -j &> /dev/null
	sed -i '3iexport PMCheck="-f11 -o2 -p1"' run.sh
	timeout 30 ./run.sh ./example 2 2 &> $BUGDIR/P-ART-3.log
	make clean &> /dev/null
        sed -i '3d' run.sh	
	git checkout -- ../Epoche.h
        git checkout -- ../example.cpp
}

function p_art_bugs {
	cd P-ART
	rm -rf build
	mkdir build
	cd build
	cmake CMAKE_CXX_FLAGS= -DCMAKE_C_COMPILER=/home/vagrant/pmcheck-vmem/Test/gcc -DCMAKE_CXX_COMPILER=/home/vagrant/pmcheck-vmem/Test/g++ -DCMAKE_C_FLAGS=-fheinous-gnu-extensions ..
	
	p_art_bug_1
	p_art_bug_2
	p_art_bug_3

	cd ../../
}

function compare_psan_jaaru {
	setup_result_dir
	cceh_bugs
	fast_fair_bugs
	p_art_bugs
	#p_bwtree_bugs
	#p_clht_bugs
	#p_masstree_bugs
	
}

compare_psan_jaaru
exit

# 3rd Bug
sed -i "46 c\#ifndef MYBUG" ../example.cpp
sed -i '3iexport PMCheck="-f11"' run.sh
make -j
timeout 30 ./run.sh ./example 2 2 &> $BUGDIR/P-ART-3.log
if [ $? -eq 124 ]; then
    echo "ERROR: The test case terminated by hitting the timeout." >> $BUGDIR/P-ART-3.log
fi
sed -i "46 c\#ifdef BUGFIX" ../example.cpp

############################### Bugs in P-BwTree
cd P-BwTree
rm -rf build
mkdir build
sed -i '4iset(CMAKE_CXX_FLAGS "-DMYBUG=1")' CMakeLists.txt
sed -i '3iexport PMCheck="-f11"' run.sh
cd build
cmake CMAKE_CXX_FLAGS=-DMYBUG=1 -DCMAKE_C_COMPILER=/home/vagrant/pmcheck-vmem/Test/gcc -DCMAKE_CXX_COMPILER=/home/vagrant/pmcheck-vmem/Test/g++ -DCMAKE_C_FLAGS=-fheinous-gnu-extensions ..
# 1st Bug
sed -i "177 c\#ifdef BUGFIX" ../example.cpp
make -j
timeout 10 ./run.sh ./example 2 2 &> $BUGDIR/P-BwTree-Bug-1.log
sed -i "177 c\#ifndef BUGFIX" ../example.cpp
# 2nd Bug
sed -i "457 c\#ifndef MYBUG" ../src/bwtree.h
make -j
timeout 30 ./run.sh ./example 8 2 &> $BUGDIR/P-BwTree-Bug-2.log
sed -i "457 c\#ifdef BUGFIX" ../src/bwtree.h
# 3rd bugs
sed -i "471 c\#ifndef MYBUG" ../src/bwtree.h
make -j
timeout 10 ./run.sh ./example 10 2 &> $BUGDIR/P-BwTree-Bug-3.log
sed -i "471 c\#ifdef BUGFIX" ../src/bwtree.h
# 4th bugs
sed -i "2000 c\#ifndef MYBUG" ../src/bwtree.h
make -j
timeout 10 ./run.sh ./example 2 2 &> $BUGDIR/P-BwTree-Bug-4.log
sed -i "2000 c\#ifdef BUGFIX" ../src/bwtree.h
# 5th bugs
sed -i "2792 c\#ifndef MYBUG" ../src/bwtree.h
make -j
timeout 10 ./run.sh ./example 2 2 &> $BUGDIR/P-BwTree-Bug-5.log
sed -i "2792 c\#ifdef BUGFIX" ../src/bwtree.h
git checkout -- ../src/bwtree.h
sed -i '3d' ../run.sh
sed -i '4d' ../CMakeLists.txt
cd ../../


############################### Bugs in P-CLHT
cd P-CLHT
rm -rf build
mkdir build
sed -i '4iset(CMAKE_CXX_FLAGS "-DMYBUG=1")' CMakeLists.txt
sed -i '3iexport PMCheck=""' run.sh
cd build
cmake -DCMAKE_C_COMPILER=/home/vagrant/pmcheck-vmem/Test/gcc -DCMAKE_CXX_COMPILER=/home/vagrant/pmcheck-vmem/Test/g++ -DCMAKE_C_FLAGS=-fheinous-gnu-extensions ..
# 1st Bug: It didn't crash
sed -i "172 c\#ifdef DISABLEFIX" ../src/clht_lf_res.c
make -j
timeout 30 ./run.sh ./example 2 2 &> $BUGDIR/P-CLHT-Bug-1.log
sed -i "172 c\#ifdef BUGFIX" ../src/clht_lf_res.c
# 2nd bug
sed -i "224 c\#ifdef DISABLEFIX" ../src/clht_lf_res.c
make -j
timeout 30 ./run.sh ./example 2 2 &> $BUGDIR/P-CLHT-Bug-2.log
sed -i "224 c\#ifdef BUGFIX" ../src/clht_lf_res.c
# 3rd bug
sed -i "227 c\#ifdef DISABLEFIX" ../src/clht_lf_res.c
make -j
sed -i '3 c\export PMCheck="-f11"' run.sh
timeout 30 ./run.sh ./example 2 2 &> $BUGDIR/P-CLHT-Bug-3.log
if [ $? -eq 124 ]; then
    echo "ERROR: The test case terminated by hitting the timeout." >> $BUGDIR/P-CLHT-Bug-3.log
fi
sed -i "227 c\#ifdef BUGFIX" ../src/clht_lf_res.c
sed -i '3d' ../run.sh
sed -i '4d' ../CMakeLists.txt
cd ../../


############################### Bugs in P-MassTree
cd P-Masstree
rm -rf build
mkdir build
sed -i '4iset(CMAKE_CXX_FLAGS "-DMYBUG=1")' CMakeLists.txt
sed -i '3iexport PMCheck="-f11"' run.sh
cd build
cmake CMAKE_CXX_FLAGS=-DMYBUG=1 -DCMAKE_C_COMPILER=/home/vagrant/pmcheck-vmem/Test/gcc -DCMAKE_CXX_COMPILER=/home/vagrant/pmcheck-vmem/Test/g++ -DCMAKE_C_FLAGS=-fheinous-gnu-extensions ..
# 1st Bug:
sed -i "1341 c\#ifndef MYBUG" ../masstree.h
make -j
timeout 10 ./run.sh ./example 20 10 &> $BUGDIR/P-Masstree-1.log
sed -i "1341 c\#ifdef BUGFIX" ../masstree.h
sed -i '3d' ../run.sh
sed -i '4d' ../CMakeLists.txt
cd ../../

