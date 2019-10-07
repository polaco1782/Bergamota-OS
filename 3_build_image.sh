#!/bin/bash

if [[ $(id -u) -ne 0 ]] ; then echo "Please run as root" ; exit 0 ; fi

kpartx -d bergamotaOS.img

rm bergamotaOS.img 2>/dev/null
fallocate -l 1G bergamotaOS.img

sfdisk bergamotaOS.img << EOF
,100M,c
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

# broadcom stuff, kernel,proprietary blobs and license
cp -va firmware/boot/* /mnt 2>/dev/null
cp -va firmware/extra/* /mnt 2>/dev/null

# default boot configuration
cp -v config.txt /mnt
cp -v cmdline.txt /mnt
umount /mnt

# format and mount secondary partition
mkfs.ext4 -F /dev/mapper/$part3
mount /dev/mapper/$part3 /mnt

sleep 5

# copy strapped root files
cp -aHx target-rootfs/* /mnt

# install kernel modules
mkdir -p /mnt/lib/modules
cp -va firmware/modules/*-v8* /mnt/lib/modules 2>/dev/null

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
