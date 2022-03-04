# PSan on Vagrant (Artifact Evaluation)

This artifact contains a vagrant repository that downloads and compiles the source code for PSan (a plugin for Jaaru), its companion compiler pass, and benchmarks.  The artifact enables users to reproduce the bugs that are found by PSan in [PMDK](https://github.com/uci-plrg/jaaru-pmdk) and [RECIPE](https://github.com/uci-plrg/nvm-benchmarks/tree/psan/RECIPE) as well as comparing bug-finding capabilities and performance of PSan with Jaaru, a persistent memory model checker.

Our workflow has four primary parts: (1) creating a virtual machine and installing dependencies needed to reproduce our results, (2) downloading the source code of PSan and the benchmarks and building them, (3) providing the parameters corresponding to each bug to reproduce the bugs, and (4) Comparing bug-finding capabilities PSan with the Jaaru (The underlying model checker) on how automatically PSan suggests fixes found by Jaaru. After the experiment, the corresponding output files are generated for each bug.

To simplify the evaluation process, we created an instance of VM that includes all the source code and corresponding binary files. This VM is fully set up and it is available on [Zenodo repository](https://doi.org/10.5281/zenodo.6326792). 


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
    $ wget https://zenodo.org/record/6326792/files/psan-artifact.box?download=1
    $ vagrant box add psan-artifact psan-artifact.box 
```

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

1. Run *compare-jaarru.sh* script to regenerate bugs found by Jaaru and see how PSan can find those bugs and suggests the corresponding fixes for them. When it finishes successfully, it generates the corresponding output file for each bug in *~/results/compare-jaaru* directory. 

```
	vagrant@ubuntu-bionic:~$ ./compare-jaaru.sh
```

After execution of this script,  *~/results/compare-jaaru* directory has the following content:

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
    log.log-FAST_FAIR  log.log-P-BwTree  log.log-P-Masstree  log.log-ctree  log.log-hashmap_tx      **performance.out**
```

## Notes

Note that the performance results generated for the benchmarks can be different from the numbers that are reported in PSan's paper since there is non-determinism in scheduling threads; when stores, flushes, and fences leave the store buffer; and memory alignment in the malloc procedure. This non-determinism can possibly impact on the number of bugs reported in [PSan Bug Report](https://docs.google.com/spreadsheets/d/1-mdVpUVSlNed-QQhgMBEyxjSJC4wXgxgTOgvggVr-K4/edit?usp=sharing) or PSan's paper for RECIPE and PMDK benchmarks.

## Disclaimer

We make no warranties that PSan is free of errors. Please read the paper and the README file so that you understand what the tool is supposed to do.

## Contact

Please feel free to contact us for more information. Bug reports are welcome, and we are happy to hear from our users. Contact Hamed Gorjiara at [hgorjiar@uci.edu](mailto:hgorjiar@uci.edu), Weiyu Luo at [weiyul7@uci.edu](mailto:weiyul7@uci.edu), Alex Lee at [leea19@uci.edu](mailto:leea19@uci.edu), Harry Xu at [harryxu@g.ucla.edu](mailto:harryxu@g.ucla.edu), or Brian Demsky at [bdemsky@uci.edu](mailto:bdemsky@uci.edu) for any questions about PSan. 

## Copyright

Copyright &copy; 2022 Regents of the University of California. All rights reserved
