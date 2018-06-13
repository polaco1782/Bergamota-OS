#!/bin/bash

if [[ $(id -u) -ne 0 ]] ; then echo "Please run as root" ; exit 0 ; fi

rm -f bergamotaOS.img
rm -rf target-rootfs

cd linux
make clean
