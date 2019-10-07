#!/bin/bash

if [[ $(id -u) -eq 0 ]] ; then echo "Please run as normal user!" ; exit 0 ; fi

# RPI firmware (boot kernel)
git clone --depth 1 https://github.com/raspberrypi/firmware.git
