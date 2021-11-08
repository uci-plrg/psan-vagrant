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

function p_bwtree_bug_1 {
	sed -i '168d' ../example.cpp
	sed -i '69d' ../src/bwtree.h
	make -j &> /dev/null
	sed -i '3iexport PMCheck="-f11 -o2 -p1"' run.sh
	timeout 10 ./run.sh ./example 2 2 &> $BUGDIR/P-BwTree-Bug-1.log
	make clean &> /dev/null
        sed -i '3d' run.sh
        git checkout -- ../src/bwtree.h
        git checkout -- ../example.cpp
}

function p_bwtree_bug_2 {
	sed -i '471d' ../src/bwtree.h
	sed -i '69d' ../src/bwtree.h
	make -j &> /dev/null
	sed -i '3iexport PMCheck="-f11 -o2 -p1"' run.sh
	timeout 30 ./run.sh ./example 8 2 &> $BUGDIR/P-BwTree-Bug-2.log
	sed -i '3d' run.sh
        git checkout -- ../src/bwtree.h
}

function p_bwtree_bug_3 {
	sed -i '485d' ../src/bwtree.h
	sed -i '69d' ../src/bwtree.h
	make -j &> /dev/null
	sed -i '3iexport PMCheck="-f11 -o2 -p1"' run.sh
	timeout 10 ./run.sh ./example 10 2 &> $BUGDIR/P-BwTree-Bug-3.log
	sed -i '3d' run.sh
        git checkout -- ../src/bwtree.h
}

function p_bwtree_bug_4 {
	sed -i '2018d' ../src/bwtree.h
	sed -i '69d' ../src/bwtree.h
	make -j &> /dev/null
	sed -i '3iexport PMCheck="-f11 -o2 -p1"' run.sh
	timeout 10 ./run.sh ./example 2 2 &> $BUGDIR/P-BwTree-Bug-4.log
	sed -i '3d' run.sh
        git checkout -- ../src/bwtree.h
}

function p_bwtree_bug_5 {
	sed -i '2813d' ../src/bwtree.h
	sed -i '69d' ../src/bwtree.h
	make -j &> /dev/null
	sed -i '3iexport PMCheck="-f11 -o2 -p1"' run.sh
	timeout 10 ./run.sh ./example 2 2 &> $BUGDIR/P-BwTree-Bug-5.log
	sed -i '3d' ./run.sh
	git checkout -- ../src/bwtree.h
}

function p_bwtree_bugs {
	cd P-BwTree
	rm -rf build
	mkdir build
	cd build
	cmake CMAKE_CXX_FLAGS= -DCMAKE_C_COMPILER=/home/vagrant/pmcheck-vmem/Test/gcc -DCMAKE_CXX_COMPILER=/home/vagrant/pmcheck-vmem/Test/g++ -DCMAKE_C_FLAGS=-fheinous-gnu-extensions ..
	
	p_bwtree_bug_1
	p_bwtree_bug_2
	p_bwtree_bug_3
	p_bwtree_bug_4
	p_bwtree_bug_5

	cd ../../
}

function p_clht_bug_1 {
	sed -i '173d' ../src/clht_lf_res.c
	sed -i '31d' ../src/clht_lf_res.c
	make -j &> /dev/null
	sed -i '3iexport PMCheck="-o2 -p1"' run.sh
	timeout 30 ./run.sh ./example 2 2 &> $BUGDIR/P-CLHT-Bug-1.log
	sed -i '3d' ./run.sh
	git checkout -- ../src/clht_lf_res.c
}

function p_clht_bug_2 {
	sed -i '225d' ../src/clht_lf_res.c
        sed -i '31d' ../src/clht_lf_res.c
        make -j &> /dev/null
        sed -i '3iexport PMCheck="-o2 -p1"' run.sh
	timeout 30 ./run.sh ./example 2 2 &> $BUGDIR/P-CLHT-Bug-2.log
        sed -i '3d' ./run.sh
        git checkout -- ../src/clht_lf_res.c
}

function p_clht_bug_3 {
	sed -i '226d' ../src/clht_lf_res.c
        sed -i '31d' ../src/clht_lf_res.c
        make -j &> /dev/null
        sed -i '3iexport PMCheck="-f11 -o2 -p1"' run.sh
	timeout 30 ./run.sh ./example 2 2 &> $BUGDIR/P-CLHT-Bug-3.log
        sed -i '3d' ./run.sh
        git checkout -- ../src/clht_lf_res.c
}

function p_clht_bugs {
	cd P-CLHT
	rm -rf build
	mkdir build
	cd build
	cmake -DCMAKE_C_COMPILER=/home/vagrant/pmcheck-vmem/Test/gcc -DCMAKE_CXX_COMPILER=/home/vagrant/pmcheck-vmem/Test/g++ -DCMAKE_C_FLAGS=-fheinous-gnu-extensions ..	
	
	p_clht_bug_1
	p_clht_bug_2
	p_clht_bug_3
	
	cd ../../
}

function p_masstree_bug_1 {
	sed -i '1374d' ../masstree.h
	sed -i '1374d' ../masstree.h
        sed -i '18d' ../masstree.h
	make -j &> /dev/null
	sed -i '3iexport PMCheck="-f11 -o2 -p1"' run.sh
	timeout 10 ./run.sh ./example 20 10 &> $BUGDIR/P-Masstree-1.log
	sed -i '3d' ./run.sh
	git checkout -- ../masstree.h
}

function p_masstree_bugs {
	cd P-Masstree
	rm -rf build
	mkdir build
	cd build
	cmake CMAKE_CXX_FLAGS= -DCMAKE_C_COMPILER=/home/vagrant/pmcheck-vmem/Test/gcc -DCMAKE_CXX_COMPILER=/home/vagrant/pmcheck-vmem/Test/g++ -DCMAKE_C_FLAGS=-fheinous-gnu-extensions ..
	
	p_masstree_bug_1

	cd ../../
}

function compare_psan_jaaru {
	setup_result_dir
	cceh_bugs
	fast_fair_bugs
	p_art_bugs
	p_bwtree_bugs
	p_clht_bugs
	p_masstree_bugs
	
}

compare_psan_jaaru

