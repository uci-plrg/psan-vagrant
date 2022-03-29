# PSan on Vagrant (Artifact Evaluation)

This artifact contains a vagrant repository that downloads and compiles the source code for PSan (a plugin for Jaaru), its companion compiler pass, and benchmarks.  The artifact enables users to reproduce the bugs that are found by PSan in [PMDK](https://github.com/uci-plrg/jaaru-pmdk) and [RECIPE](https://github.com/uci-plrg/nvm-benchmarks/tree/psan/RECIPE) as well as comparing bug-finding capabilities and performance of PSan with Jaaru, a persistent memory model checker.

Our workflow has four primary parts: (1) creating a virtual machine and installing dependencies needed to reproduce our results, (2) downloading the source code of PSan and the benchmarks and building them, (3) providing the parameters corresponding to each bug to reproduce the bugs, and (4) Comparing bug-finding capabilities PSan with the Jaaru (The underlying model checker) on how automatically PSan suggests fixes found by Jaaru. After the experiment, the corresponding output files are generated for each bug.

To simplify the evaluation process, we created an instance of VM that includes all the source code and corresponding binary files. This VM is fully set up and it is available on [Zenodo repository](https://doi.org/10.5281/zenodo.6326792). This document also provides a guideline on how to setup the VM and use it to reproduce PSan's evaluation results.


## Hardware Dependencies

Our tooling system and PSan have no special hardware dependencies and it can be running on any x86 machine with at least 32GB RAM and 4 cores and 85G free disk space.

**Using our VM**: To properly import the pre-built VM instance, please verify you have enough storage on your disk (~ 200G) and you used the most recent version of Vagrant (>= 2.2.19) to avoid facing any errors.

## Getting Started Guide

1. In order for Vagrant to run, we should first make sure that the [VT-d option for virtualization is enabled in BIOS](https://docs.fedoraproject.org/en-US/Fedora/13/html/Virtualization_Guide/sect-Virtualization-Troubleshooting-Enabling_Intel_VT_and_AMD_V_virtualization_hardware_extensions_in_BIOS.html).

2. Then, you need to download and install Vagrant, if we do not have Vagrant ready on our machine. Also, it is required to install *vagrant-disksize* plugin for vagrant to specify the size of the disk needed for the evaluation.

```
    $ sudo apt update
    $ sudo apt-get install virtualbox
    $ sudo apt-get install vagrant
    $ vagrant plugin install vagrant-disksize
```

**Note:** If you encountered `conflicting dependencies fog-core (~> 1.43.0) and fog-core (= 1.45.0)` error in installing `vagrant-disksize` plugin, you need to use the most recent version of vagrant:

```
    $ wget -c https://releases.hashicorp.com/vagrant/2.2.19/vagrant_2.2.19_x86_64.deb
    $ sudo dpkg -i vagrant_2.2.19_x86_64.deb
    # Now install vagrant-disksize
    $ vagrant plugin install vagrant-disksize
```

3. **Using our VM Instance:** Use the following commands to download and setup VM: (**Note:** skip this step if you want to build the VM and all the source code)


```
    $ mkdir psan-artifact
    $ cd psan-artifact
    $ wget https://zenodo.org/record/6326792/files/psan-artifact.box
    $ vagrant box add psan-artifact psan-artifact.box 
```

**Note:** If you encountered an error in unpackaging the VM image, please verify that your machine has the proper version of Vagrant (>= 2.2.19). For updating your Vagrant, follow the instructions of **Note** section in **Step 2**. 

Then, create a 'Vagrantfile' that contains the following configurations:

```
    $ cat Vagrantfile
Vagrant.configure("2") do |config|
  config.vm.box = "psan-artifact"
  config.disksize.size = '80GB'
  config.vm.provider :virtualbox do |v|
     v.customize ["modifyvm", :id, "--memory", 28344]
     v.customize ["modifyvm", :id, "--cpus", "4"]
     v.customize ["modifyvm", :id, "--uartmode1", "disconnected"]

  end
end
```

 

4. **Building a VM Instance:** Clone this repository into the local machine and go to the *psan-vagrant* folder: (**Note:** skip this step if you are using our VM instance)

```
    $ git clone https://github.com/uci-plrg/psan-vagrant.git
    $ cd psan-vagrant
```

5. Use the following command to set up the virtual machine. Then, our scripts automatically downloads the source code for PSan, its LLVM pass, and PMDK and RECIPE. Then, it builds them and sets them up to be used. Finally, it copies the running script in the *home* directory of the virtual machine. If you are using our VM instance, the following command imports the VM and runs it on your machine.

```
    psan-vagrant $ vagrant up
```

6. After everything is set up, the virtual machine is up and the user can ssh to it by using the following command:

```
    psan-vagrant $ vagrant ssh
```

7. After logging in into the VM, there are nine script files in the 'home' directory. These scripts automatically run the corresponding benchmark and save the results in the *~/results* direcotory:

```
    vagrant@ubuntu-bionic:~$ ls
    compare-jaaru.sh  memcached-client.sh  nvm-benchmarks  perf.sh  pmcheck-vmem  pmdk-bugs.sh    redis-client.sh  results   testcase
    llvm-project      memcached-server.sh  parse.py        pmcheck  pmdk          recipe-bugs.sh  redis-server.sh  setup.sh
```

## Step-by-Step Instructions

This section provides detailed step-by-step instructions to reproduce bugs found by PSan. For each bug, PSan generates a log file (e.g., *CCEH-bug-1.log*) which contains PSan's suggestion on how the bug needs to be fixed. We analyzed suggested fixes by PSan for each bug in every benchmark and they are all listed in [PSan Bug Report](https://docs.google.com/spreadsheets/d/1-mdVpUVSlNed-QQhgMBEyxjSJC4wXgxgTOgvggVr-K4/edit?usp=sharing). In the bug report, we wrote down PSan's fix location, the variable causing the bug, and the main reason on the origin of the bug. The following steps show how to reproduce old bugs found by Jaaru, new bugs in RECIPE, new bugs in PMDK, and performance results to compare overhead of PSan vs. Jaaru: 

1. Run *compare-jaarru.sh* script to regenerate bugs found by Jaaru and see how PSan can find those bugs and suggests the corresponding fixes for them. When it finishes successfully, it generates the corresponding output file for each bug in *~/results/recipe-jaaru-bugs* directory. 

```
	vagrant@ubuntu-bionic:~$ ./compare-jaaru.sh
```

After execution of this script,  *~/results/recipe-jaaru-bugs* directory has the following content:

```
    vagrant@ubuntu-bionic:~$ ls
    CCEH-bug-1.log  CCEH-bug-3.log       FAST_FAIR-bug-2.log  P-ART-2.log         P-BwTree-Bug-3.log  P-BwTree-Bug-5.log  P-CLHT-Bug-2.log  logs
    CCEH-bug-2.log  FAST_FAIR-bug-1.log  P-ART-1.log          P-BwTree-Bug-2.log  P-BwTree-Bug-4.log  P-CLHT-Bug-1.log    P-CLHT-Bug-3.log
```

Evaluation and analysis for each of these bugs are listed in [PSan Bug Report](https://docs.google.com/spreadsheets/d/1-mdVpUVSlNed-QQhgMBEyxjSJC4wXgxgTOgvggVr-K4/edit?usp=sharing) as **Found by jaaru**.

2. Run *recipe-bugs.sh* script to regenerate bugs in RECIPE that found by PSan. Then, it generates the corresponding log file for each bug in *~/results/recipe-bugs* directory.

```
    vagrant@ubuntu-bionic:~$ ./recipe-bugs.sh
```

After execution of this script,  *~/results/recipe-bugs* directory has the following content:

```
    vagrant@ubuntu-bionic:~$ ls
    CCEH-bug-1.log  CCEH-bug-5.log       FAST_FAIR-bug-2.log  FAST_FAIR-bug-4.log  P-ART-2.log  P-ART-4.log  P-ART-6.log  P-ART-9.log         P-BwTree-Bug-1.log     logs
    CCEH-bug-3.log  FAST_FAIR-bug-1.log  FAST_FAIR-bug-3.log  P-ART-1.log          P-ART-3.log  P-ART-5.log  P-ART-8.log  P-ART-Mem-Bugs.log  P-BwTree-Mem-Bugs.log
```

Evaluation and analysis for each of these bugs are listed in [PSan Bug Report](https://docs.google.com/spreadsheets/d/1-mdVpUVSlNed-QQhgMBEyxjSJC4wXgxgTOgvggVr-K4/edit?usp=sharing) as **New**.

3. Run *pmdk-bugs.sh* script to regenerate bugs in PMDK that found by PSan. Then, it generates the corresponding log file for each bug in *~/results/pmdk-bugs* directory.

```
    vagrant@ubuntu-bionic:~$ ./pmdk-bugs.sh
```

After execution of this script,  *~/results/pmdk-bugs* directory has the following content:

```
    vagrant@ubuntu-bionic:~$ ls
    PMDK-Bug-1.log  PMDK-Bug-2.log  PMDK-Bug-3.log  PMDK-Bug-4.log  logs
```

Evaluation and analysis for each of these bugs are listed in [PSan Bug Report](https://docs.google.com/spreadsheets/d/1-mdVpUVSlNed-QQhgMBEyxjSJC4wXgxgTOgvggVr-K4/edit?usp=sharing) as **New**.

4. Run *perf.sh* script to measure the overhead of PSan compared to Jaaru, the underlying model checker. After successfully running this script, *performance.out* in *~/results/performance* will be created which contain the average execution time of running each benchmark on PSan vs. Jaaru:

```
    vagrant@ubuntu-bionic:~$ ls ~/results/performance
    log.log-CCEH       log.log-P-ART     log.log-P-CLHT      log.log-btree  log.log-hashmap_atomic  log.log-rbtree   psan-performance.csv
    log.log-FAST_FAIR  log.log-P-BwTree  log.log-P-Masstree  log.log-ctree  log.log-hashmap_tx      performance.out
    vagrant@ubuntu-bionic:~$ cat ~/results/performance/performance.out
```

## Notes

Note that the performance results generated for the benchmarks can be different from the numbers that are reported in PSan's paper since there is non-determinism in scheduling threads; when stores, flushes, and fences leave the store buffer; and memory alignment in the malloc procedure. This non-determinism can possibly impact on the number of bugs reported in [PSan Bug Report](https://docs.google.com/spreadsheets/d/1-mdVpUVSlNed-QQhgMBEyxjSJC4wXgxgTOgvggVr-K4/edit?usp=sharing) or PSan's paper for RECIPE and PMDK benchmarks.

# Use PSan

This section shows how to set up PSan on any Linux machine. Use the following step-by-step guidance to set up PSan and test any applications with it. In particular, this section describe commands in [setup.sh](https://github.com/uci-plrg/psan-vagrant/blob/master/data/setup.sh). This script can be used to setup PSan, RECIPE, PMDK, Redis, and Memcached in *home (~/)* directory of any Linux based machine. 

## Dependencies

To properly set up PSan and Our benchmarks, some packages are required. Use the following commands to install all the necessary dependencies:

```
apt-get update
apt-get -y install cmake g++ clang pkg-config autoconf pandoc libevent-dev libseccomp-dev xsltproc
```

## Building PMCPass

PSan is implemented on top of Jaaru model checker. Jaaru requires an LLVM pass (i.e., PMCPass) to annotate all memory and cache operations of your tool. You can download the binary file from [here](https://drive.google.com/drive/folders/1FH6uKohoSZXrf1Twq55ZUTI6DzNVYzts?usp=sharing) or build the PMCPass with LLVM. To build it you need to download LLVM and register our pass and build it:

```
git clone https://github.com/llvm/llvm-project.git
git clone https://github.com/uci-plrg/jaaru-llvm-pass
cd llvm-project
git checkout 7899fe9da8d8df6f19ddcbbb877ea124d711c54b
cd ../jaaru-llvm-pass
git checkout vagrant
cd ..
mv jaaru-llvm-pass llvm-project/llvm/lib/Transforms/PMCPass
```

To register our pass in LLVM append *‘add_subdirectory(PMCPass)’* to *CMakeLists.txt* file in the *‘Transforms’* directory by using the following command:

```
echo "add_subdirectory(PMCPass)" >> llvm-project/llvm/lib/Transforms/CMakeLists.txt
```

After registering the pass, use the following commands to build the pass and LLVM:

```
cd llvm-project
mkdir build
cd build
cmake -DLLVM_ENABLE_PROJECTS=clang -G "Unix Makefiles" ../llvm
make
```

To verify the building process was successful, our pass can be found in the following directory:

```
touch llvm-project/build/lib/libPMCPass.so
```

## Setting up PSan

This section shows how to set up PSan and use it to debug your tool. First, we need to checkout Jaaru, the underlying model checker, which contains PSan plugin. Then, use the following commands to build PSan:

```
cd ~/
git clone https://github.com/uci-plrg/jaaru.git
mv jaaru pmcheck
cd pmcheck/
git checkout psan
# Setting LLVMDIR and JAARUDIR in wrapper scripts
sed -i 's/LLVMDIR=.*/LLVMDIR=~\/llvm-project\//g' Test/gcc
sed -i 's/JAARUDIR=.*/JAARUDIR=~\/pmcheck\/bin\//g' Test/gcc
sed -i 's/LLVMDIR=.*/LLVMDIR=~\/llvm-project\//g' Test/g++
sed -i 's/JAARUDIR=.*/JAARUDIR=~\/pmcheck\/bin\//g' Test/g++
# Building test cases
make test
```

PSan supports different APIs to access the persistent memory including [pmem](https://github.com/pmem/pmdk/) in PMDK library and volatile memory allocator ([libvmemmalloc](https://pmem.io/pmdk/manpages/linux/v1.3/libvmmalloc.3.html)). In PMDK there are separate APIs for allocating persistent memory. However, libvmemmalloc overrides normal malloc APIs to allocate memory on persistent memory instead of DRAM. If the tool-under-test uses libvmemmalloc, a flag needs to be set in PSan to activate the corresponding support. Otherwise, PSan supports pmem APIs by default. To enable libvmemmalloc, uncomment the following flag in ‘pmcheck/config.h’ file and recompile Jaaru:

```
//In config.h file uncomment the following line
#define ENABLE_VMEM
```

The source code for PSan plugin can be found in *'Plugins'* directory in [pmverifier.cc](https://github.com/uci-plrg/jaaru/blob/pmrace/Plugins/pmverifier.cc). Jaaru is capable of being extended to implement different plugins for different analyses. To implement a new plugin, the [Analysis](https://github.com/uci-plrg/jaaru/blob/pmrace/Plugins/analysis.h) interface need to be implemnted. Then, similar to *PMVerifier*, enable it in [main.cc](https://github.com/uci-plrg/jaaru/blob/ac78a7a2fb0e7ddcadb38e0adcac7724ab034dfc/main.cc#L149) file.

## Running PSan test cases

PSan test cases are located in the *‘Test’* directory. To run them with PSan, we need to modify *‘run.sh’* script to become as follows:

```
#!/bin/bash
export LD_LIBRARY_PATH=~/pmcheck/bin/
# For Mac OSX
export DYLD_LIBRARY_PATH=~/pmcheck/bin/
export PMCheck="-o"
echo $@
$@
```

By using ‘PMCheck’ environment variable, we can set different options for Jaaru. To see a full list of Jaaru’s options, set PMCheck=”–help” and run the test cases. For example, to run ‘[testverifier](https://github.com/uci-plrg/jaaru/blob/psan/Test/testverifier.cc)‘ test case use the following commands:

```
cd ~/pmcheck
make test
cd bin
./run.sh testverifier
```

*PMCheck=”-o”* enables PSan plugin in Jaaru. PSan support different strategies in dealing with robustness violations: 1) Naive: which reports the bug and continues exploring the execution 2) Exit: which exits the execution once it finds a violation 3) Safe: which forces to explore robustness-free stores for each load. By default, PSan choose Naive strategy. Other strategies can be selected by using ‘PMCheck’ variable. For example for choosing Exist strategy use:

```
export PMCheck="-o2"
```

PSan can operate in two different modes: 1) Random mode: which randomly selects and explore executions and 2) Model checking mode: which systematically insert crashes and explore executions. By default, Model Checking mode is selected for PSan. To enable model checking mode, we need to use “-x” option. For example, for activating random mode to exploring 100 random execution with Safe strategy, we need to run PSan with the following parameter:

```
export PMCheck="-o3 -x100"
```

## Running your tools

To test your application with PSan, you need to compile your tool with PSan and our LLVM pass (i.e., PMCPass). To make this process easier, we use a coding pattern which is described as follows: If you check ‘pmcheck/Test’ directory, there are 4 scripting files g++, gcc, clang, and clang++. In each of these files, we define appropriate flags for the compiler. You can modify ‘LLVMDIR’ and ‘JAARUDIR’ environment variables in these files to point to the location of LLVM and Jaaru (i.e., PMCheck) on your machine. Then, modify the building system of your tool to use these script wrappers instead of the actual compilers. For example, your ‘~/pmcheck/Test/g++’ file can look like this:

```
LLVMDIR=~/llvm-project/
CC=${LLVMDIR}/build/bin/clang++
LLVMPASS=${LLVMDIR}/build/lib/libPMCPass.so
JAARUDIR=~/pmcheck/bin/
$CC -Xclang -load -Xclang $LLVMPASS -L${JAARUDIR} -lpmcheck -Wno-unused-command-line-argument -Wno-address-of-packed-member -Wno-mismatched-tags -Wno-unused-private-field -Wno-constant-conversion -Wno-null-dereference $@
```

To verify the script wrappers you can build our test cases without any errors:

```
cd ~/pmcheck/
make test
```

## Exmaple: Debugging RECIPE

We tested PSan on [RECIPE](https://github.com/utsaslab/RECIPE) benchmarks which we branched off [this commit version](https://github.com/utsaslab/RECIPE/commit/bab7b1f8d14e2a968285d89cac6b3dc7fddc5f5b) of the original repository. RECIPE uses libvmemmalloc to access persistent memory, so vmem flag has to be activated to debug this benchmark (See **Setting up PSan**). Here you can download the working version of the RECIPE that contains our bug fixes from our repository:

```
git clone https://github.com/uci-plrg/nvm-benchmarks
cd nvm-benchmarks
git checkout psan
# Or use: git checkout e4bfded2cc4baddcd5e848beeb9cdc6641f1e955 
cd RECIPE
```

To compile and run any benchmarks, you need to modify the Makefile to change the compiler to point to the corresponding wrapper script. For example in FAST_FAIR makefile add the following line to ‘Makefile’:

```
CXX=~/pmcheck/Test/g++
```

To run each test case, you need to modify the ‘run.sh’ file in ‘FAST_FAIR’ directory to look like the following:

```
#!/bin/bash
export LD_LIBRARY_PATH=~/pmcheck/bin/
export PMCheck="-o2"
$@
```

Now you can run RECIPE benchmarks by using ‘run.sh’ script file. For instance, to run FAST_FAIR with two threads and 3 keys we use the following command:

```
./run.sh ./example 3 2
```

### Debugging with GDB

PSan supports running under GDB to debug your program further. To use GDB, add ‘-g’ option to ‘CFLAGS‘ and ‘CPPFLAGS‘ variables in pmcheck/common.mk. Then recompile PSan and your tool and use gdb to run your program. For example, you can run FAST_FAIR example with gdb by using the following commands:

```
./run.sh gdb ./example
(gdb) run 3 2
```

## Exmaple 2: Debugging PMDK

We tested PSan on [PMDK](https://github.com/pmem/pmdk) benchmarks which we branched off [this commit version](https://github.com/pmem/pmdk/commit/9afe20553b44420ad3626a7335dafe3d34fdced7) of the original repository. PMDK test cases use libpmem to access persistent memory, so vmem flag has to be disabled to debug these test cases (See **Setting up PSan**). Here you can download the working version of the PMDK that contains our bug fixes from our repository:

```
git clone https://github.com/uci-plrg/jaaru-pmdk.git
mv jaaru-pmdk pmdk
cd pmdk
git checkout psan
# Or use: git checkout 1637c48c0d4c3884dbcfe7ca5d608b30cc98e31e
```

To compile and run PMDK test cases, you need to compile PMDK with setting flags to change the compiler to point to the corresponding wrapper script. For example PMDK can be compiled with the following command:

```
make EXTRA_CFLAGS_RELEASE="-ggdb -fno-omit-frame-pointer -O0" CC=~/pmcheck/Test/gcc CXX=~/pmcheck/Test/g++
```

To run each test case, you need to create the ‘run.sh’ file in ‘src/examples/libpmemobj/map/’ directory to look like the following:

```
#!/bin/bash
export NDCTL_ENABLE=n
export LD_LIBRARY_PATH=~/pmcheck/bin/:~/pmdk/src/debug
# For Mac OSX
export DYLD_LIBRARY_PATH=~/pmcheck/bin/
export PMCheck="-d$3 -o -r1000"
echo "./run.sh ./data_store <ctree|btree|rbtree|hashmap_atomic|hashmap_tx> ./path/to/file [number of inserts]"
echo $@
$@
```

Now you can run test cases by using ‘run.sh’ script file. For instance, to run *btree* with 2 inserts, we use the following command:

```
./run.sh ./data_store btree tmp.log 2
```

# Disclaimer

We make no warranties that PSan is free of errors. Please read the paper and the README file so that you understand what the tool is supposed to do.

# Contact

Please feel free to contact us for more information. Bug reports are welcome, and we are happy to hear from our users. Contact Hamed Gorjiara at [hgorjiar@uci.edu](mailto:hgorjiar@uci.edu), Weiyu Luo at [weiyul7@uci.edu](mailto:weiyul7@uci.edu), Alex Lee at [leea19@uci.edu](mailto:leea19@uci.edu), Harry Xu at [harryxu@g.ucla.edu](mailto:harryxu@g.ucla.edu), or Brian Demsky at [bdemsky@uci.edu](mailto:bdemsky@uci.edu) for any questions about PSan. 

# Copyright

Copyright &copy; 2022 Regents of the University of California. All rights reserved
