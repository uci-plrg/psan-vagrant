#!/bin/bash
if [[ $1 -eq 1 ]]
then
    echo "set foo 0 0 6"
    echo "fooval"
    echo "add bar 0 0 6"
    echo "barval"
    echo "replace bar 0 0 6"
    echo "barva2"
    echo "set moo 0 0 6"
    echo "MOOVAL"
    echo "cas moo 0 0 6 0"
    echo "MOOVAL"
    echo "set nu 0 0 1"
    echo "1"
    echo "incr nu 1"
    echo "incr nu 8"
    echo "decr nu 1"
    echo "quit"
    echo "set boo 0 0 6"
    echo "booval"
    echo "shutdown";
else
    echo "get foo"
    echo "get bar"
    echo "get moo"
    echo "get nu"
    echo "quit"
    echo "shutdown";
fi
sleep 3;
