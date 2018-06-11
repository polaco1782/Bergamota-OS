#!/bin/bash

if [[ $(id -u) -eq 0 ]] ; then echo "Please run as normal user!" ; exit 0 ; fi

cd linux
make -j4
