#!/bin/bash

if [[ $(id -u) -ne 0 ]] ; then echo "Please run as root" ; exit 0 ; fi

kpartx -d bergamotaOS.img

rm bergamotaOS.img 2>/dev/null
fallocate -l 1G bergamotaOS.img

sfdisk bergamotaOS.img << EOF
,50M,c
,256M,82
,
EOF

# mount and map output image file partition
kpartx -a bergamotaOS.img

# ensure all files/devices are sync'ed and visible
sync; sleep 1; sync;

eval $(kpartx -l bergamotaOS.img | awk '{print "part"NR"="$1}')

# format and mount primary partition
mkfs.vfat -F 32 /dev/mapper/$part1
mkswap -f /dev/mapper/$part2
mount /dev/mapper/$part1 /mnt
mkdir /mnt/overlays

# broadcom stuff, proprietary blobs and license
cp -v firmware/boot/COPYING.linux /mnt
cp -v firmware/boot/LICENCE.broadcom /mnt
cp -v firmware/boot/bootcode.bin /mnt
cp -v firmware/boot/fixup.dat /mnt
cp -v firmware/boot/fixup_cd.dat /mnt
cp -v firmware/boot/fixup_db.dat /mnt
cp -v firmware/boot/fixup_x.dat /mnt
cp -v firmware/boot/start.elf /mnt
cp -v firmware/boot/start_cd.elf /mnt
cp -v firmware/boot/start_db.elf /mnt
cp -v firmware/boot/start_x.elf /mnt

# default boot configuration
cp -v config.txt /mnt
cp -v cmdline.txt /mnt

# ARM-v8 linux kernel and device tree
cp -v linux/arch/arm64/boot/Image /mnt/kernel8.img
cp -v linux/arch/arm64/boot/dts/broadcom/*.dtb /mnt
umount /mnt

# format and mount secondary partition
mkfs.ext4 -F /dev/mapper/$part3
mount /dev/mapper/$part3 /mnt

sleep 5

# install kernel modules
make -C linux modules_install INSTALL_MOD_PATH=/mnt

# copy strapped root files
cp -aHx target-rootfs/* /mnt

# copy overlay files
for f in $(find overlay/* | sed 's/overlay\///');
do
   install -vD -o root -g root overlay/$f /mnt/$f
done

# remove generated SSH keys
rm -f /mn/etc/ssh/ssh_host_*

umount /mnt

kpartx -d bergamotaOS.img

sync

echo "Done!"
