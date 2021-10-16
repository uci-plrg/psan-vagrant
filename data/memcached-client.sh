#!/bin/bash

# Run pre-crash client
./testcase/memcachedtestcase.sh 1 | telnet localhost 11211

read  -n 1 -p "Press any keys to start Post-rash client.." mainmenuinput

# Run post-crash client
./testcase/memcachedtestcase.sh 0 | telnet localhost 11212
