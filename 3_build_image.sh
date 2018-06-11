#!/bin/bash

if [[ $(id -u) -ne 0 ]] ; then echo "Please run as root" ; exit 0 ; fi

# format and mount primary partition
mkfs.vfat -F 32 /dev/sdb1
mount /dev/sdb1 /mnt
mkdir /mnt/overlays

# broadcom stuff, proprietary blobs and license
cp -v rpi-proprietary/COPYING.linux /mnt
cp -v rpi-proprietary/LICENCE.broadcom /mnt
cp -v rpi-proprietary/bootcode.bin /mnt
cp -v rpi-proprietary/fixup.dat /mnt
cp -v rpi-proprietary/fixup_cd.dat /mnt
cp -v rpi-proprietary/fixup_db.dat /mnt
cp -v rpi-proprietary/fixup_x.dat /mnt
cp -v rpi-proprietary/start.elf /mnt
cp -v rpi-proprietary/start_cd.elf /mnt
cp -v rpi-proprietary/start_db.elf /mnt
cp -v rpi-proprietary/start_x.elf /mnt

# default boot configuration
cp -v config.txt /mnt
cp -v cmdline.txt /mnt

# ARM-v8 linux kernel and device trees
cp -v linux/arch/arm64/boot/Image /mnt/kernel8.img
cp -v linux/arch/arm64/boot/dts/broadcom/*.dtb /mnt
cp -v linux/arch/arm64/boot/dts/overlays/*.dtbo /mnt/overlays/
cp -v linux/arch/arm64/boot/dts/overlays/README /mnt/overlays/
umount /mnt

# format and mount secondary partition
mkfs.ext4 -F /dev/sdb2
mount /dev/sdb2 /mnt

# install kernel modules
make -C linux modules_install INSTALL_MOD_PATH=/mnt

# copy strapped root and overlay user files
cp -avHx target-rootfs/* /mnt
cp -avHx overlay/* /mnt
umount /mnt