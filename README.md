# PSan on Vagrant (Artifact Evaluation)

This artifact contains a vagrant repository that downloads and compiles the source code for PSan (a plugin for Jaaru), its companion compiler pass, and benchmarks.  The artifact enables users to reproduce the bugs that are found by PSan in [PMDK](https://github.com/uci-plrg/jaaru-pmdk) and [RECIPE](https://github.com/uci-plrg/nvm-benchmarks/tree/psan/RECIPE) as well as comparing bug-finding capabilities of PSan with Jaaru, a persistent memory model checker.

Our workflow has four primary parts: (1) creating a virtual machine and installing dependencies needed to reproduce our results, (2) downloading the source code of PSan and the benchmarks and building them, (3) providing the parameters corresponding to each bug to reproduce the bugs, and (4) Comparing bug-finding capabilities PSan with the Jaaru (The underlying model checker) on how automatically PSan suggests fixes found by Jaaru. After the experiment, the corresponding output files are generated for each bug.

## Step-by-step guidance

1. In order for Vagrant to run, we should first make sure that the [VT-d option for virtualization is enabled in BIOS](https://docs.fedoraproject.org/en-US/Fedora/13/html/Virtualization_Guide/sect-Virtualization-Troubleshooting-Enabling_Intel_VT_and_AMD_V_virtualization_hardware_extensions_in_BIOS.html).

2. Then, you need to download and install Vagrant, if we do not have Vagrant ready on our machine. Also, it is required to install *vagrant-disksize* plugin for vagrant to specify the size of the disk needed for the evaluation.

```
    $ sudo apt-get install virtualbox
    $ sudo apt-get install vagrant
    $ vagrant plugin install vagrant-disksize
```

3. Clone this repository into the local machine and go to the *pmrace-vagrant* folder:

```
    $ git clone https://github.com/uci-plrg/psan-vagrant.git
    $ cd psan-vagrant
```

4. Use the following command to set up the virtual machine. Then, our scripts automatically downloads the source code for PSan, its LLVM pass, and PMDK and RECIPE. Then, it builds them and sets them up to be used. Finally, it copies the running script in the *home* directory of the virtual machine. 

```
    psan-vagrant $ vagrant up
```

5. After everything is set up, the virtual machine is up and the user can ssh to it by using the following command:

```
    psan-vagrant $ vagrant ssh
```

6. After logging in into the VM, there are three script files in the 'home' directory. These scripts automatically run the corresponding benchmark and save the results in the *~/results* direcotory:

```
    vagrant@ubuntu-bionic:~$ ls
    llvm-project  nvm-benchmarks  pmcheck  pmcheck-vmem  pmdk  pmdk-bugs.sh  recipe-bugs.sh  recipe-perf.sh
```

7. Run *compare-jaarru.sh* script to regenerate bugs found by Jaaru and see how PSan can find those bugs and suggests the corresponding fixes for them. When it finishes successfully, it generates the corresponding output file for each bug in *~/results/compare-jaaru* directory. 

```
	vagrant@ubuntu-bionic:~$ ./compare-jaaru.sh
```

8. Run *recipe-bugs.sh* script to regenerate bugs in RECIPE that found by PSan. Then, it generates the corresponding log file for each bug in *~/results/recipe-bugs* directory.

```
    vagrant@ubuntu-bionic:~$ ./recipe-bugs.sh
```

9. Run *pmdk-bugs.sh* script to regenerate bugs in PMDK that found by PSan. Then, it generates the corresponding log file for each bug in *~/results/pmdk-bugs* directory.

```
    vagrant@ubuntu-bionic:~$ ./pmdk-bugs.sh
```


## Disclaimer

We make no warranties that PSan is free of errors. Please read the paper and the README file so that you understand what the tool is supposed to do.

## Contact

Please feel free to contact us for more information. Bug reports are welcome, and we are happy to hear from our users. Contact Hamed Gorjiara at [hgorjiar@uci.edu](mailto:hgorjiar@uci.edu), Harry Xu at [harryxu@g.ucla.edu](mailto:harryxu@g.ucla.edu), or Brian Demsky at [bdemsky@uci.edu](mailto:bdemsky@uci.edu) for any questions about PSan. 
