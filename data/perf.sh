#!/bin/bash
set -ex


## Setup
RESULTDIR=~/results
PERFDIR=$RESULTDIR/performance
OUTFILE=$PERFDIR/random-performance.csv
LOG=$PERFDIR/log.log
mkdir -p $RESULTDIR
rm -rf $PERFDIR
mkdir -p $PERFDIR
echo 'Benchmark, Baseline(s), PMRace(s), # Prefix Bugs, # Naive Bugs' > $OUTFILE
GCCCOMPILER=/home/vagrant/pmcheck-vmem/Test/gcc
GXXCOMPILER=/home/vagrant/pmcheck-vmem/Test/g++


## RECIPE evaluation for -x1
BENCHMARKDIR=~/nvm-benchmarks/RECIPE
cd $BENCHMARKDIR

run_cceh() {
	BENCHMARKNAME=CCEH
	cd $BENCHMARKNAME
	echo "Compiling $BENCHMARKNAME ..."
	git checkout -- run.sh
	sed -i '3s/CFLAGS.*/CFLAGS := -std=c++17 -I. -lpthread -O0 -g -DCLWB=1/' Makefile
	sed -i '3iexport PMCheck="-x1"' run.sh
	make &> /dev/null
	echo "Running $BENCHMARKNAME on Jaaru ..."
	start=`date +%s.%N`
	for i in {1..100}; do
		sed -i "3s/export PMCheck.*/export PMCheck=\"-x1 -a${i}\"/" run.sh
		./run.sh ./example 30 4 &> /dev/null
	done
	end=`date +%s.%N`
	JAARU=$( echo "$end/100 - $start/100" | bc -l )
	sed -i '3s/export PMCheck.*/export PMCheck="-x1 -y"/' run.sh
	echo "Running $BENCHMARKNAME on PMRace ..."
	./run.sh ./example 30 4 &> $LOG
	start=`date +%s.%N`
	for i in {1..100}; do
		sed -i "3s/export PMCheck.*/export PMCheck=\"-x1 -y -a${i}\"/" run.sh
		./run.sh ./example 30 4 &> /dev/null
	done
	end=`date +%s.%N`
	PMRACE=$( echo "$end/100 - $start/100" | bc -l )
	PREFIX=$(grep "Number of distinct prefix-execution bugs" $LOG | grep -o -E '[0-9]+')
	NAIVE=$(grep "Number of distinct full-execution bugs" $LOG | grep -o -E '[0-9]+')
	echo "$BENCHMARKNAME, $JAARU, $PMRACE, $PREFIX, $NAIVE" >> $OUTFILE
	# Cleaning up
	sed -i '3d' run.sh
	sed -i '3s/CFLAGS.*/CFLAGS := -std=c++17 -I. -lpthread -O0 -g -DCLFLUSH_OPT=1/' Makefile
	make clean &> /dev/null
	mv $LOG "$LOG-$BENCHMARKNAME"
	cd ..
}

run_fast() {
	BENCHMARKNAME=FAST_FAIR
        cd $BENCHMARKNAME
        echo "Compiling $BENCHMARKNAME ..."
        git checkout -- run.sh
	sed -i '7s/CFLAGS.*/CFLAGS=-O0 -std=c++11 -g -DCLWB=1/' Makefile
       	sed -i '3iexport PMCheck="-x1"' run.sh 
        make &> /dev/null
        echo "Running $BENCHMARKNAME on Jaaru ..."
        start=`date +%s.%N`
        for i in {1..100}; do
		sed -i "3s/export PMCheck.*/export PMCheck=\"-x1 -a${i}\"/" run.sh
                ./run.sh ./example 30 3 &> /dev/null
        done
        end=`date +%s.%N`
        JAARU=$( echo "$end/100 - $start/100" | bc -l )
        sed -i '3s/export PMCheck.*/export PMCheck="-x1 -y"/' run.sh
        echo "Running $BENCHMARKNAME on PMRace ..."
        ./run.sh ./example 30 4 &> $LOG
        start=`date +%s.%N`
        for i in {1..100}; do
		sed -i "3s/export PMCheck.*/export PMCheck=\"-x1 -y -a${i}\"/" run.sh
                ./run.sh ./example 30 3 &> /dev/null
        done
        end=`date +%s.%N`
        PMRACE=$( echo "$end/100 - $start/100" | bc -l )
        PREFIX=$(grep "Number of distinct prefix-execution bugs" $LOG | grep -o -E '[0-9]+')
        NAIVE=$(grep "Number of distinct full-execution bugs" $LOG | grep -o -E '[0-9]+')
        echo "$BENCHMARKNAME, $JAARU, $PMRACE, $PREFIX, $NAIVE" >> $OUTFILE
        # Cleaning up
	sed -i '3d' run.sh
	sed -i '7s/CFLAGS.*/CFLAGS=-O0 -std=c++11 -g -DCLFLUSH_OPT=1/' Makefile
	make clean &> /dev/null
	mv $LOG "$LOG-$BENCHMARKNAME"
	cd ..
}

run_p_benchmarks() {
	BENCHMARKNAME=$1
        cd $BENCHMARKNAME
        echo "Compiling $BENCHMARKNAME ..."
        rm -rf build
	mkdir build
	cd build
	cmake -D CMAKE_C_COMPILER=$GCCCOMPILER -D CMAKE_CXX_COMPILER=$GXXCOMPILER -D ENABLE_CLWB=1 .. &> /dev/null
        make &> /dev/null
	sed -i '3iexport PMCheck="-x1"' run.sh
        echo "Running $BENCHMARKNAME on Jaaru ..."
        start=`date +%s.%N`
        for i in {1..100}; do
		sed -i "3s/export PMCheck.*/export PMCheck=\"-x1 -a${i}\"/" run.sh
                ./run.sh ./example $2 $3 &> /dev/null
        done
        end=`date +%s.%N`
        JAARU=$( echo "$end/100 - $start/100" | bc -l )
        sed -i '3s/export PMCheck.*/export PMCheck="-x1 -y"/' run.sh
        echo "Running $BENCHMARKNAME on PMRace ..."
        ./run.sh ./example $2 $3 &> $LOG
        start=`date +%s.%N`
        for i in {1..100}; do
		sed -i "3s/export PMCheck.*/export PMCheck=\"-x1 -y -a${i}\"/" run.sh
                ./run.sh ./example $2 $3 &> /dev/null
        done
        end=`date +%s.%N`
        PMRACE=$( echo "$end/100 - $start/100" | bc -l )
        PREFIX=$(grep "Number of distinct prefix-execution bugs" $LOG | grep -o -E '[0-9]+')
        NAIVE=$(grep "Number of distinct full-execution bugs" $LOG | grep -o -E '[0-9]+')
        echo "$BENCHMARKNAME, $JAARU, $PMRACE, $PREFIX, $NAIVE" >> $OUTFILE
        # Cleaning up
        cd ..
	rm -rf build
	mv $LOG "$LOG-$BENCHMARKNAME"
	cd ../
}

run_recipe() {
	run_cceh
	run_fast
	run_p_benchmarks P-ART 30 4
	run_p_benchmarks P-BwTree 7 2
	run_p_benchmarks P-CLHT 30 4
	run_p_benchmarks P-Masstree 25 5
}

run_pmdk_benchmark() {
	BENCHMARKNAME=$1
	sed -i '5s/export PMCheck.*/export PMCheck="-d$3 -x1 -r1000"/' run.sh
        echo "Running $BENCHMARKNAME on Jaaru ..."
        start=`date +%s.%N`
        for i in {1..100}; do
		sed -i "5s/export PMCheck.*/export PMCheck=\"-d\$3 -x1 -r1000 -a${i}\"/" run.sh
                ./run.sh ./data_store $BENCHMARKNAME ./tmp.log 2 &> /dev/null
        done
        end=`date +%s.%N`
        JAARU=$( echo "$end/100 - $start/100" | bc -l )
	sed -i '5s/export PMCheck.*/export PMCheck="-d$3 -y -x1 -r1000"/' run.sh
        echo "Running $BENCHMARKNAME on PMRace ..."
        ./run.sh ./data_store $BENCHMARKNAME ./tmp.log 2 &> $LOG
        start=`date +%s.%N`
        for i in {1..100}; do
		sed -i "5s/export PMCheck.*/export PMCheck=\"-d\$3 -y -x1 -r1000 -a${i}\"/" run.sh
                ./run.sh ./data_store $BENCHMARKNAME ./tmp.log 2 &> /dev/null
        done
        end=`date +%s.%N`
        PMRACE=$( echo "$end/100 - $start/100" | bc -l )
        PREFIX=$(grep "Number of distinct prefix-execution bugs" $LOG | grep -o -E '[0-9]+')
        NAIVE=$(grep "Number of distinct full-execution bugs" $LOG | grep -o -E '[0-9]+')
        echo "$BENCHMARKNAME, $JAARU, $PMRACE, $PREFIX, $NAIVE" >> $OUTFILE
	mv $LOG "$LOG-$BENCHMARKNAME"
}

run_pmdk() {
	BENCHMARKDIR=~/pmdk
	cd $BENCHMARKDIR/src/examples/libpmemobj/map/
	echo '#!/bin/bash' > run.sh
	echo 'export NDCTL_ENABLE=n' >> run.sh
	echo 'export LD_LIBRARY_PATH=~/pmcheck/bin/:~/pmdk/src/debug' >> run.sh
	echo 'export DYLD_LIBRARY_PATH=~/pmcheck/bin/' >> run.sh
	echo 'export PMCheck="-d$3 -y -x1 -r1000"' >> run.sh
	echo '$@' >> run.sh
	chmod +x run.sh
	run_pmdk_benchmark btree
	run_pmdk_benchmark ctree
	run_pmdk_benchmark rbtree
	run_pmdk_benchmark hashmap_atomic
	run_pmdk_benchmark hashmap_tx
}

run_redis() {
	BENCHMARKDIR=~/nvm-benchmarks/redis/
	cd $BENCHMARKDIR
	BENCHMARKNAME=redis
	echo "Running $BENCHMARKNAME on Jaaru ..."
	rm -f redis.pm
	rm -f dump.rdb
	sed -i '6s/export PMCheck.*/export PMCheck="-d.\/redis.pm -x1 -p1 -e -r2000"/' run.sh
	sed -i '6s/export PMCheck.*/export PMCheck="-d.\/redis.pm -x1 -p1 -e -r2000"/' $BENCHMARKDIR/run2.sh
	start=`date +%s.%N`
	for i in {1..100}; do
		sed -i "6s/export PMCheck.*/export PMCheck=\"-d.\/redis.pm -x1 -p1 -e -r2000 -a${i}\"/" run.sh
                ./run.sh ./src/redis-server ./redis.conf &> /dev/null &
		sleep 2
		~/testcase/redistestcase.sh 1 | $BENCHMARKDIR/run2.sh $BENCHMARKDIR/src/redis-cli &> /dev/null
		sleep 2
		~/testcase/redistestcase.sh 0 | $BENCHMARKDIR/run2.sh $BENCHMARKDIR/src/redis-cli &> /dev/null
		rm -f redis.pm
        	rm -f dump.rdb
        done
	end=`date +%s.%N`
	JAARU=$( echo "$end/100 - $start/100" | bc -l )
	sed -i '6s/export PMCheck.*/export PMCheck="-d.\/redis.pm -x1 -p1 -y -e -r2000"/' run.sh
        sed -i '6s/export PMCheck.*/export PMCheck="-d.\/redis.pm -x1 -p1 -y -e -r2000"/' $BENCHMARKDIR/run2.sh
	echo "Running $BENCHMARKNAME on PMRace ..."
	./run.sh ./src/redis-server ./redis.conf &> $LOG &
	sleep 2
	~/testcase/redistestcase.sh 1 | $BENCHMARKDIR/run2.sh $BENCHMARKDIR/src/redis-cli &> /dev/null
	sleep 2
	~/testcase/redistestcase.sh 0 | $BENCHMARKDIR/run2.sh $BENCHMARKDIR/src/redis-cli &> /dev/null
	rm -f redis.pm
        rm -f dump.rdb
	start=`date +%s.%N`
        for i in {1..100}; do
		sed -i "6s/export PMCheck.*/export PMCheck=\"-d.\/redis.pm -x1 -p1 -y -e -r2000 -a${i}\"/" run.sh
		./run.sh ./src/redis-server ./redis.conf &> /dev/null &
        	sleep 2
		~/testcase/redistestcase.sh 1 | $BENCHMARKDIR/run2.sh $BENCHMARKDIR/src/redis-cli &> /dev/null
        	sleep 2
        	~/testcase/redistestcase.sh 0 | $BENCHMARKDIR/run2.sh $BENCHMARKDIR/src/redis-cli &> /dev/null
		rm -f redis.pm
        	rm -f dump.rdb
	done
	end=`date +%s.%N`
	PMRACE=$( echo "$end/100 - $start/100" | bc -l )
        PREFIX=$(grep "Number of distinct prefix-execution bugs" $LOG | grep -o -E '[0-9]+')
        NAIVE=$(grep "Number of distinct full-execution bugs" $LOG | grep -o -E '[0-9]+')
        echo "$BENCHMARKNAME, $JAARU, $PMRACE, $PREFIX, $NAIVE" >> $OUTFILE
	mv $LOG "$LOG-$BENCHMARKNAME"
}

run_memcached() {
	set +e
	BENCHMARKDIR=~/nvm-benchmarks/memcached/
        cd $BENCHMARKDIR
        BENCHMARKNAME=memcached
        echo "Running $BENCHMARKNAME on Jaaru ..."
	rm -f foo
	sed -i '6s/export PMCheck.*/export PMCheck="-dfoo -x1 -p1 -e -r2000"/' run.sh
	start=`date +%s.%N`
	for i in {1..100}; do
		sed -i "6s/export PMCheck.*/export PMCheck=\"-dfoo -x1 -p1 -e -r2000 -a${i}\"/" run.sh
		./run.sh ./memcached &> /dev/null &
		sleep 1
		~/testcase/memcachedtestcase.sh 1 | telnet localhost 11211 &> /dev/null
		sleep 1
		~/testcase/memcachedtestcase.sh 0 | telnet localhost 11212 &> /dev/null
		rm -f foo
	done
	end=`date +%s.%N`
        JAARU=$( echo "$end/100 - $start/100" | bc -l )
	sed -i '6s/export PMCheck.*/export PMCheck="-dfoo -x1 -p1 -y -e -r2000"/' run.sh
	# Change pmcheck
	PMRACEDIR=~/pmcheck
	cd $PMRACEDIR
	sed -i '331i    complete=true;' Model/model.cc
	make
	cd $BENCHMARKDIR
	echo "Running $BENCHMARKNAME on PMRace ..."
	./run.sh ./memcached &> $LOG &
        sleep 1
        ~/testcase/memcachedtestcase.sh 1 | telnet localhost 11211 &> /dev/null
        sleep 1
        ~/testcase/memcachedtestcase.sh 0 | telnet localhost 11212 &> /dev/null
	rm -f foo
	## Reverting changes in PMRace
	cd $PMRACEDIR
	git checkout -- Model/model.cc
	make
	cd $BENCHMARKDIR

	start=`date +%s.%N`
        for i in {1..100}; do
		sed -i "6s/export PMCheck.*/export PMCheck=\"-dfoo -x1 -p1 -y -e -r2000 -a${i}\"/" run.sh
		 ./run.sh ./memcached &> /dev/null &
        	sleep 1
        	~/testcase/memcachedtestcase.sh 1 | telnet localhost 11211 &> /dev/null
        	sleep 1
        	~/testcase/memcachedtestcase.sh 0 | telnet localhost 11212 &> /dev/null
	done
	end=`date +%s.%N`
        PMRACE=$( echo "$end/100 - $start/100" | bc -l )
        PREFIX=$(grep "Number of distinct prefix-execution bugs" $LOG | grep -o -E '[0-9]+')
        NAIVE=$(grep "Number of distinct full-execution bugs" $LOG | grep -o -E '[0-9]+')
        echo "$BENCHMARKNAME, $JAARU, $PMRACE, $PREFIX, $NAIVE" >> $OUTFILE
	mv $LOG "$LOG-$BENCHMARKNAME"
}

run_recipe
run_pmdk
run_redis
run_memcached

## Cleanup
cat $OUTFILE | sed 's/,/ ,/g' | column -t -s, &> $PERFDIR/performance.out

