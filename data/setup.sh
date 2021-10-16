#!/bin/bash
set -e
# change this flag to false to get LLVM source code instead of using binary files
USELLVMBIN=false


# 1. Getting all the source code

git clone https://github.com/uci-plrg/jaaru.git
mv jaaru pmcheck
cd pmcheck/
git checkout psan
cd ..

git clone https://github.com/uci-plrg/nvm-benchmarks.git
cd nvm-benchmarks
git checkout psan
rm -rf redis
git clone https://github.com/uci-plrg/memcached-pmem
mv memcached-pmem memcached
cd memcached
git checkout pmrace
cd ..
git clone https://github.com/uci-plrg/redis.git
cd redis
git checkout pmrace
cd ~/

git clone https://github.com/uci-plrg/jaaru-pmdk.git
mv jaaru-pmdk pmdk
cd pmdk
git checkout psan
cd ..

if ! $USELLVMBIN
then
	# 2. Compiling the LLVM Pass
	git clone https://github.com/llvm/llvm-project.git
	cd llvm-project
	git checkout 7899fe9da8d8df6f19ddcbbb877ea124d711c54b
	cd ..

	git clone https://github.com/uci-plrg/jaaru-llvm-pass.git
	mv jaaru-llvm-pass PMCPass
	cd PMCPass
	git checkout vagrant
	cd ..

	mv PMCPass llvm-project/llvm/lib/Transforms/
	echo "add_subdirectory(PMCPass)" >> llvm-project/llvm/lib/Transforms/CMakeLists.txt
	cd llvm-project
	mkdir build
	cd build
	cmake -DLLVM_ENABLE_PROJECTS=clang -DCMAKE_BUILD_TYPE=Release -G "Unix Makefiles" ../llvm
	make -j 4
	cd ~/
	touch llvm-project/build/lib/libPMCPass.so
else
	# 2. Using the LLVM binary files
	cp /vagrant/data/llvm-project.tar.gz .
	tar -xzvf llvm-project.tar.gz
	rm llvm-project.tar.gz
fi

# 3. Compiling Jaaru (PMCheck) with default libpmem API
cd pmcheck/
sed -i 's/LLVMDIR=.*/LLVMDIR=~\/llvm-project\//g' Test/gcc
sed -i 's/JAARUDIR=.*/JAARUDIR=~\/pmcheck\/bin\//g' Test/gcc

sed -i 's/LLVMDIR=.*/LLVMDIR=~\/llvm-project\//g' Test/g++
sed -i 's/JAARUDIR=.*/JAARUDIR=~\/pmcheck\/bin\//g' Test/g++
make test
cd ~/

# 4. Building PMDK
cd pmdk
# Creating run.sh
echo '#!/bin/bash' > src/examples/libpmemobj/map/run.sh
echo 'export NDCTL_ENABLE=n' >> src/examples/libpmemobj/map/run.sh
echo 'export LD_LIBRARY_PATH=/scratch/nvm/pmcheck/bin/:/scratch/nvm/pmdk/src/debug' >> src/examples/libpmemobj/map/run.sh
echo 'export DYLD_LIBRARY_PATH=/scratch/nvm/pmcheck/bin/' >> src/examples/libpmemobj/map/run.sh
echo 'export PMCheck="-d$3 -o -r1000"' >> src/examples/libpmemobj/map/run.sh
echo '$@' >> src/examples/libpmemobj/map/run.sh

sed -i 's/export LD_LIBRARY_PATH=.*/export LD_LIBRARY_PATH=~\/pmcheck\/bin\//g' src/examples/libpmemobj/map/run.sh
sed -i 's/export DYLD_LIBRARY_PATH=.*/export DYLD_LIBRARY_PATH=~\/pmcheck\/bin\//g' src/examples/libpmemobj/map/run.sh
make EXTRA_CFLAGS_RELEASE="-ggdb -fno-omit-frame-pointer -O0" CC=~/pmcheck/Test/gcc CXX=~/pmcheck/Test/g++
cd ~/

# 5. Compiling Jaaru (PMCheck) with libvmmalloc configuration
cp -r pmcheck pmcheck-vmem
cd pmcheck-vmem
sed -i 's/JAARUDIR=.*/JAARUDIR=~\/pmcheck-vmem\/bin\//g' Test/gcc
sed -i 's/JAARUDIR=.*/JAARUDIR=~\/pmcheck-vmem\/bin\//g' Test/g++
sed -i 's/.*\#define ENABLE_VMEM.*/\#define ENABLE_VMEM/g' config.h
make clean
make test
cd ~/

# 6. Compiling RECIPE benchmarks
cd nvm-benchmarks
sed -i 's/export LD_LIBRARY_PATH=.*/export LD_LIBRARY_PATH=~\/pmcheck-vmem\/bin\//g' run
cd RECIPE

#Initializing CCEH
cd CCEH
sed -i 's/CXX := \/.*/CXX := ~\/pmcheck-vmem\/Test\/g++/g' Makefile
cd ..

#Initializing FAST_FAIR
cd FAST_FAIR
sed -i 's/CXX=.*/CXX=~\/pmcheck-vmem\/Test\/g++/g' Makefile
cd ..

#initializing P-ART, P-BwTree, P-CLHT, P-Masstree, and P-HOT
RECIPE_BENCH="P-ART P-BwTree P-CLHT P-Masstree"
for bench in $RECIPE_BENCH; do
        cd $bench
        sed -i 's/set(CMAKE_C_COMPILER .*)/set(CMAKE_C_COMPILER "\/home\/vagrant\/pmcheck-vmem\/Test\/gcc")/g' CMakeLists.txt
        sed -i 's/set(CMAKE_CXX_COMPILER .*)/set(CMAKE_CXX_COMPILER "\/home\/vagrant\/pmcheck-vmem\/Test\/g++")/g' CMakeLists.txt
        sed -i 's/export LD_LIBRARY_PATH=.*/export LD_LIBRARY_PATH=~\/pmcheck-vmem\/bin\//g' run.sh
        sed -i 's/export DYLD_LIBRARY_PATH=.*/export DYLD_LIBRARY_PATH=~\/pmcheck-vmem\/bin\//g' run.sh
        cd ..
done
cd ..

# 7. Initializing redis
cd redis
sed -i 's/export LD_LIBRARY_PATH=.*/export LD_LIBRARY_PATH=~\/pmcheck\/bin\/:~\/pmdk\/src\/debug\//g' run.sh
sed -i 's/export DYLD_LIBRARY_PATH=.*/export DYLD_LIBRARY_PATH=~\/pmcheck\/bin\/:~\/pmdk\/src\/debug\//g' run.sh
sed -i '27s/CC=.*/CC=~\/pmcheck\/Test\/gcc/g' src/Makefile
rm deps/pmdk
ln -s ~/pmdk deps/pmdk
make USE_PMDK=yes STD=-std=gnu99
cd ..

# 8. Initializing Memcached
cd memcached
sed -i 's/export LD_LIBRARY_PATH=.*/export LD_LIBRARY_PATH=~\/pmcheck\/bin\/:~\/pmdk\/src\/debug\//g' run.sh
sed -i 's/export DYLD_LIBRARY_PATH=.*/export DYLD_LIBRARY_PATH=~\/pmcheck\/bin\/:~\/pmdk\/src\/debug\//g' run.sh
./configure --enable-pslab CFLAGS="-O0 -g -I/home/vagrant/pmcheck/Memory"
make CC=~/pmcheck/Test/gcc
cd ..

# 9. Copying the generator scritps
cd ~/
cp /vagrant/data/*.sh ~/
cp -r /vagrant/data/testcase ~/
