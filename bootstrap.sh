#!/bin/bash
apt-get update
apt-get -y install cmake g++ clang pkg-config autoconf pandoc libevent-dev libseccomp-dev xsltproc

time su -c /vagrant/data/setup.sh vagrant

