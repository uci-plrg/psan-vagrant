#!/bin/bash
set -e
######################################## Defining variables
BENCHMARKDIR=~/pmdk
RESULTDIR=~/results
LOGDIR=$RESULTDIR/pmdk
STRATEGY=-o2
######################################### Running Jaaru to find bugs
cd $BENCHMARKDIR
mkdir -p $RESULTDIR
rm -rf $LOGDIR
mkdir $LOGDIR
cd $BENCHMARKDIR/src/examples/libpmemobj/map/
# Creating run.sh
echo '#!/bin/bash' > run.sh
echo 'export NDCTL_ENABLE=n' >> run.sh
echo 'export LD_LIBRARY_PATH=~/pmcheck/bin/:~/pmdk/src/debug' >> run.sh
echo 'export DYLD_LIBRARY_PATH=~/pmcheck/bin/' >> run.sh
echo "export PMCheck=\"-d\$3 ${STRATEGY} -r1787250\"" >> run.sh
echo '$@' >> run.sh
chmod +x run.sh

function btree_bug {
	BENCHMARKNAME=btree
	echo "Running $BENCHMARKNAME ..."
	TREELOG=$LOGDIR/$BENCHMARKNAME-1.log
	sed -i "5s/export PMCheck.*/export PMCheck=\"-d\$3 ${STRATEGY} -r1787250\"/" run.sh
	./run.sh ./data_store $BENCHMARKNAME ./tmp.log 1 &> $TREELOG
	TREELOG=$LOGDIR/$BENCHMARKNAME-2.log
	sed -i "5s/export PMCheck.*/export PMCheck=\"-d\$3 ${STRATEGY}\"/" run.sh
	./run.sh ./data_store $BENCHMARKNAME ./tmp.log 2 &> $TREELOG
}

function ctree_bug {
	BENCHMARKNAME=ctree
	echo "Running $BENCHMARKNAME ..."
	TREELOG=$LOGDIR/$BENCHMARKNAME-1.log
	sed -i "5s/export PMCheck.*/export PMCheck=\"-d\$3 ${STRATEGY} -r1800000\"/" run.sh
	./run.sh ./data_store $BENCHMARKNAME ./tmp.log 1 &> $TREELOG
}

function rbtree_bug {
	BENCHMARKNAME=rbtree
	echo "Running $BENCHMARKNAME ..."
	TREELOG=$LOGDIR/$BENCHMARKNAME-org.log
	sed -i "5s/export PMCheck.*/export PMCheck=\"-d\$3 ${STRATEGY} -r1790000\"/" run.sh
	./run.sh ./data_store $BENCHMARKNAME ./tmp.log 1 &> $TREELOG
}

function hashmap_atomic_bug {
	BENCHMARKNAME=hashmap_atomic
	echo "Running $BENCHMARKNAME ..."
	TREELOG=$LOGDIR/$BENCHMARKNAME-1.log
	sed -i "5s/export PMCheck.*/export PMCheck=\"-d\$3 ${STRATEGY} -e\"/" run.sh
	sed -i '33ivoid jaaru_enable_simulating_crash(void);' data_store.c
	sed -i '233ijaaru_enable_simulating_crash();' data_store.c
	make EXTRA_CFLAGS_RELEASE="-ggdb -fno-omit-frame-pointer -O0" CC=~/pmcheck/Test/gcc CXX=~/pmcheck/Test/g++ &> /dev/null
	./run.sh ./data_store $BENCHMARKNAME ./tmp.log 2 &> $TREELOG
	sed -i '233d' data_store.c
	sed -i '237ijaaru_enable_simulating_crash();' data_store.c
	make EXTRA_CFLAGS_RELEASE="-ggdb -fno-omit-frame-pointer -O0" CC=~/pmcheck/Test/gcc CXX=~/pmcheck/Test/g++ &> /dev/null
	TREELOG=$LOGDIR/$BENCHMARKNAME-2.log
	./run.sh ./data_store $BENCHMARKNAME ./tmp.log 1 &> $TREELOG
	git checkout -- data_store.c
	make EXTRA_CFLAGS_RELEASE="-ggdb -fno-omit-frame-pointer -O0" CC=~/pmcheck/Test/gcc CXX=~/pmcheck/Test/g++ &> /dev/null
}

function hashmap_tx_bug {
	sed -i "5s/export PMCheck.*/export PMCheck=\"-d\$3 ${STRATEGY} -e\"/" run.sh
	sed -i '33ivoid jaaru_enable_simulating_crash(void);' data_store.c
	sed -i '237ijaaru_enable_simulating_crash();' data_store.c
	make EXTRA_CFLAGS_RELEASE="-ggdb -fno-omit-frame-pointer -O0" CC=~/pmcheck/Test/gcc CXX=~/pmcheck/Test/g++ &> /dev/null
	BENCHMARKNAME=hashmap_tx
	echo "Running $BENCHMARKNAME ..."
	TREELOG=$LOGDIR/$BENCHMARKNAME-org.log
	./run.sh ./data_store $BENCHMARKNAME ./tmp.log 1 &> $TREELOG
	git checkout -- data_store.c
	make EXTRA_CFLAGS_RELEASE="-ggdb -fno-omit-frame-pointer -O0" CC=~/pmcheck/Test/gcc CXX=~/pmcheck/Test/g++ &> /dev/null
}

btree_bug
#ctree_bug
#rbtree_bug
#hashmap_atomic_bug
hashmap_tx_bug

rm -f PMCheckOutput* tmp.log
