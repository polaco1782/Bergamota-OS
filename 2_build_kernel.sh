#!/bin/bash

export ARCH=arm64
export CROSS_COMPILE=aarch64-linux-gnu-

if [[ $(id -u) -eq 0 ]] ; then echo "Please run as normal user!" ; exit 0 ; fi

# RPI kernel 4.19 repository
git clone --depth 1 --branch rpi-4.19.y https://github.com/raspberrypi/linux.git

cd linux
make bcmrpi3_defconfig
make -j4

cd ..

# RPI firmware (boot kernel)
git clone --depth 1 https://github.com/raspberrypi/firmware.git
