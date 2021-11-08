#!/bin/bash
set -x

STRATEGY=-o2

function setup_result_dir {
	cd ~/nvm-benchmarks/RECIPE
	RESULTDIR=~/results
	mkdir -p $RESULTDIR
	BUGDIR=$RESULTDIR/recipe-bugs
	rm -rf $BUGDIR
	mkdir $BUGDIR
}

function cceh_bug_1 {
	# Sema variable bug
	sed -i '23d' src/CCEH_LSB.cpp
	make &> /dev/null
	sed -i "3iexport PMCheck=\"-x100 ${STRATEGY} -p1\"" run.sh
	./run.sh ./example 30 4 >> $BUGDIR/CCEH-bug-1.log
	make clean &> /dev/null
	git checkout -- src/CCEH_LSB.cpp
	git checkout -- run.sh
}

function cceh_bug_2 {
	# TODO: Need to recheck this bug
	# Key variable bug
	sed -i '33d' src/CCEH_LSB.cpp
	make &> /dev/null
	sed -i "3iexport PMCheck=\"-x10000 ${STRATEGY} -p1\"" run.sh
	./run.sh ./example 30 4 >> $BUGDIR/CCEH-bug-2.log
	make clean &> /dev/null
	git checkout -- src/CCEH_LSB.cpp
	git checkout -- run.sh
}

function cceh_bug_3 {
	# key variable bug
	sed -i '39d' src/CCEH_LSB.cpp
	make &> /dev/null
	sed -i "3iexport PMCheck=\"-x1000 ${STRATEGY} -p1\"" run.sh
	./run.sh ./example 30 4 >> $BUGDIR/CCEH-bug-3.log
	make clean &> /dev/null
	git checkout -- src/CCEH_LSB.cpp
	git checkout -- run.sh
}

function cceh_bug_3 {
        # key variable bug
        sed -i '39d' src/CCEH_LSB.cpp
        make &> /dev/null
        sed -i "3iexport PMCheck=\"-x1000 ${STRATEGY} -p1\"" run.sh
        ./run.sh ./example 30 4 >> $BUGDIR/CCEH-bug-3.log
        make clean &> /dev/null
        git checkout -- src/CCEH_LSB.cpp
        git checkout -- run.sh
}

function cceh_bug_4 {
        # TODO: Need to recheck this bug
	# Sema variable bug
        sed -i '49d' src/CCEH_LSB.cpp
        make &> /dev/null
        sed -i "3iexport PMCheck=\"-x1000 ${STRATEGY} -p1\"" run.sh
        ./run.sh ./example 30 4 >> $BUGDIR/CCEH-bug-4.log
        make clean &> /dev/null
        git checkout -- src/CCEH_LSB.cpp
        git checkout -- run.sh
}

function cceh_bug_5 {
        # key variable bug
        sed -i '55d' src/CCEH_LSB.cpp
        make &> /dev/null
        sed -i "3iexport PMCheck=\"-x1000 ${STRATEGY} -p1\"" run.sh
        ./run.sh ./example 30 4 >> $BUGDIR/CCEH-bug-5.log
        make clean &> /dev/null
        git checkout -- src/CCEH_LSB.cpp
        git checkout -- run.sh
}

function cceh_run {
        # key variable bug
        make &> /dev/null
        sed -i "3iexport PMCheck=\"-x10000 ${STRATEGY} -p1\"" run.sh
        ./run.sh ./example 125 6 >> $BUGDIR/CCEH-Run.log
        make clean &> /dev/null
        git checkout -- run.sh
}

function cceh_bugs {
	cd CCEH
	make clean
	
	cceh_bug_1
	#cceh_bug_2
	cceh_bug_3
	#cceh_bug_4
	cceh_bug_5

	git checkout -- Makefile
	sed -i 's/CXX := \/.*/CXX := ~\/pmcheck-vmem\/Test\/g++/g' Makefile
	cd ..
}

function fast_fair_bug_1 {
	# switch_counter bug
	sed -i '586d' btree.h
	make &> /dev/null
        sed -i "3iexport PMCheck=\"-x1000 ${STRATEGY} -p1\"" run.sh
	./run.sh ./example 30 4 &>> $BUGDIR/FAST_FAIR-bug-1.log
	make clean &> /dev/null
	git checkout -- btree.h
        git checkout -- run.sh
}

function fast_fair_bug_2 {
	# last_index bug
	sed -i '653d' btree.h
	make &> /dev/null
        sed -i "3iexport PMCheck=\"-x1000 ${STRATEGY} -p1\"" run.sh
	./run.sh ./example 30 4 &>> $BUGDIR/FAST_FAIR-bug-2.log
	make clean &> /dev/null
	git checkout -- btree.h
        git checkout -- run.sh
}

function fast_fair_bug_3 {
        # header class bug
        sed -i '654d' btree.h
        sed -i '652d' btree.h
	sed -i '587d' btree.h
	sed -i '585d' btree.h
	sed -i '24d' btree.h
        make
        sed -i "3iexport PMCheck=\"-x1000 ${STRATEGY} -p1\"" run.sh
        ./run.sh ./example 30 4 &>> $BUGDIR/FAST_FAIR-bug-3.log
        make clean &> /dev/null
        git checkout -- btree.h
        git checkout -- run.sh
}

function fast_fair_bug_4 {
        # ptr bug
        sed -i '605d' btree.h
        make &> /dev/null
        sed -i "3iexport PMCheck=\"-x1000 ${STRATEGY} -p1\"" run.sh
        ./run.sh ./example 126 6 &>> $BUGDIR/FAST_FAIR-bug-4.log
        make clean &> /dev/null
        git checkout -- btree.h
        git checkout -- run.sh
}

function fast_fair_run {
        make
        sed -i "3iexport PMCheck=\"-x10000 ${STRATEGY} -p1\"" run.sh
        ./run.sh ./example 125 6 &>> $BUGDIR/FAST_FAIR-Run.log
        make clean &> /dev/null
        git checkout -- run.sh
}

function fast_fair_bugs {
	cd FAST_FAIR
	
	fast_fair_bug_1
	fast_fair_bug_2
	fast_fair_bug_3
	fast_fair_bug_4
	fast_fair_run

	git checkout -- Makefile
	sed -i 's/CXX=.*/CXX=~\/pmcheck-vmem\/Test\/g++/g' Makefile
	cd ..
}

function p_art_bug_1 {
	sed -i '99d' ../N.cpp
	make -j &> /dev/null
        sed -i "3iexport PMCheck=\"-x1000 ${STRATEGY} -p1\"" run.sh
	./run.sh ./example 30 4 &> $BUGDIR/P-ART-1.log
	make clean &> /dev/null
	sed -i '3d' run.sh
	git checkout -- ../N.cpp
}

function p_art_bug_2 {
	sed -i '110d' ../N.cpp
	make -j &> /dev/null
        sed -i "3iexport PMCheck=\"-x1000 ${STRATEGY} -p1\"" run.sh
	./run.sh ./example 30 4 &> $BUGDIR/P-ART-2.log
	make clean &> /dev/null
	sed -i '3d' run.sh
	git checkout -- ../N.cpp
}

function p_art_bug_3 {
	sed -i '121d' ../N.cpp
	make -j &> /dev/null
        sed -i "3iexport PMCheck=\"-x1000 ${STRATEGY} -p1\"" run.sh
	./run.sh ./example 30 4 &> $BUGDIR/P-ART-3.log
	make clean &> /dev/null
	sed -i '3d' run.sh
	git checkout -- ../N.cpp
}

function p_art_bug_4 {
	sed -i '23d' ../N4.cpp
	make -j &> /dev/null
        sed -i "3iexport PMCheck=\"-x1000 ${STRATEGY} -p1\"" run.sh
	./run.sh ./example 30 4 &> $BUGDIR/P-ART-4.log
	make clean &> /dev/null
	sed -i '3d' run.sh
	git checkout -- ../N4.cpp
}

function p_art_bug_5 {
	sed -i '27d' ../N4.cpp
	make -j &> /dev/null
        sed -i "3iexport PMCheck=\"-x1000 ${STRATEGY} -p1\"" run.sh
	./run.sh ./example 30 4 &> $BUGDIR/P-ART-5.log
	make clean &> /dev/null
	sed -i '3d' run.sh
	git checkout -- ../N4.cpp
}

function p_art_bug_6 {
	sed -i '14d' ../N16.cpp
	make -j &> /dev/null
        sed -i "3iexport PMCheck=\"-x1000 ${STRATEGY} -p1\"" run.sh
	./run.sh ./example 30 4 &> $BUGDIR/P-ART-6.log
	make clean &> /dev/null
	sed -i '3d' run.sh
	git checkout -- ../N16.cpp
}

function p_art_bug_7 {
        sed -i '93d' ../Epoche.h
        sed -i '90d' ../Epoche.h
        make -j &> /dev/null
        sed -i "3iexport PMCheck=\"-x1000 ${STRATEGY} -p1\"" run.sh
        ./run.sh ./example 30 4 &> $BUGDIR/P-ART-Mem-Bugs.log
        make clean &> /dev/null
        sed -i '3d' run.sh
        git checkout -- ../Epoche.h
}

function p_art_bug_8 {
        sed -i '21d' ../N16.cpp
        make -j &> /dev/null
        sed -i "3iexport PMCheck=\"-x1000 ${STRATEGY} -p1\"" run.sh
        ./run.sh ./example 125 6 &> $BUGDIR/P-ART-8.log
        make clean &> /dev/null
        sed -i '3d' run.sh
        git checkout -- ../N16.cpp
}

function p_art_bug_9 {
        sed -i '68d' ../Epoche.cpp
        make -j &> /dev/null
        sed -i "3iexport PMCheck=\"-x1000 ${STRATEGY} -p1\"" run.sh
        ./run.sh ./example 100 6 &> $BUGDIR/P-ART-9.log
        make clean &> /dev/null
        sed -i '3d' run.sh
        git checkout -- ../Epoche.cpp
}

function p_art_run {
        make -j &> /dev/null
        sed -i "3iexport PMCheck=\"-x10000 ${STRATEGY} -p1\"" run.sh
        ./run.sh ./example 125 6 &> $BUGDIR/P-ART-Run.log
        make clean &> /dev/null
        sed -i '3d' run.sh
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
	p_art_bug_4
	p_art_bug_5
	p_art_bug_6
	p_art_bug_7
	p_art_bug_8
	p_art_bug_9
	p_art_run

	cd ../../
}

function p_bwtree_bug_1 {
	sed -i '69d' ../src/bwtree.h
	make -j &> /dev/null
        sed -i "3iexport PMCheck=\"-x10000 ${STRATEGY} -p1\"" run.sh
	./run.sh ./example 7 2 &> $BUGDIR/P-BwTree-Bug-1.log
	make clean &> /dev/null
        sed -i '3d' run.sh
        git checkout -- ../src/bwtree.h
}

function p_bwtree_bug_2 {
        sed -i '2091d' ../src/bwtree.h
        make -j &> /dev/null
        sed -i "3iexport PMCheck=\"-x1000 ${STRATEGY} -p1\"" run.sh
        timeout 300 ./run.sh ./example 45 4 &> $BUGDIR/P-BwTree-Bug-2.log
        make clean &> /dev/null
        sed -i '3d' run.sh
        git checkout -- ../src/bwtree.h
}

function p_bwtree_run {
	make -j &> /dev/null
        sed -i "3iexport PMCheck=\"-x10000 ${STRATEGY} -p1\"" run.sh
	./run.sh ./example 125 6 &> $BUGDIR/P-BwTree-Run.log
	make clean &> /dev/null
        sed -i '3d' run.sh
}


function p_bwtree_bugs {
	cd P-BwTree
	rm -rf build
	mkdir build
	cd build
	cmake CMAKE_CXX_FLAGS= -DCMAKE_C_COMPILER=/home/vagrant/pmcheck-vmem/Test/gcc -DCMAKE_CXX_COMPILER=/home/vagrant/pmcheck-vmem/Test/g++ -DCMAKE_C_FLAGS=-fheinous-gnu-extensions ..
	
	p_bwtree_bug_1
	p_bwtree_bug_2
	p_bwtree_run
	
	cd ../../
}

function p_clht_run {
	make -j &> /dev/null
        sed -i "3iexport PMCheck=\"-x10000 ${STRATEGY} -p1\"" run.sh
	./run.sh ./example 125 6 &> $BUGDIR/P-CLHT-Run.log
	sed -i '3d' ./run.sh
}

function p_clht_bugs {
	cd P-CLHT
	rm -rf build
	mkdir build
	cd build
	cmake -DCMAKE_C_COMPILER=/home/vagrant/pmcheck-vmem/Test/gcc -DCMAKE_CXX_COMPILER=/home/vagrant/pmcheck-vmem/Test/g++ -DCMAKE_C_FLAGS=-fheinous-gnu-extensions ..	
	
	p_clht_run
	
	cd ../../
}

function p_masstree_run {
	make -j &> /dev/null
        sed -i "3iexport PMCheck=\"-x10000 ${STRATEGY} -p1\"" run.sh
	./run.sh ./example 125 6 &> $BUGDIR/P-Masstree-Run.log
	sed -i '3d' ./run.sh
}

function p_masstree_bugs {
	cd P-Masstree
	rm -rf build
	mkdir build
	cd build
	cmake CMAKE_CXX_FLAGS= -DCMAKE_C_COMPILER=/home/vagrant/pmcheck-vmem/Test/gcc -DCMAKE_CXX_COMPILER=/home/vagrant/pmcheck-vmem/Test/g++ -DCMAKE_C_FLAGS=-fheinous-gnu-extensions ..
	
	p_masstree_run

	cd ../../
}

function find_recipe_bugs {
	setup_result_dir
	cceh_bugs
	fast_fair_bugs
	p_art_bugs
	p_bwtree_bugs
	p_clht_bugs
	p_masstree_bugs
	
}

find_recipe_bugs

