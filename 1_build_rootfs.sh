#!/bin/bash

if [[ $(id -u) -ne 0 ]] ; then echo "Please run as root" ; exit 0 ; fi

TARGET_ROOTFS_DIR="target-rootfs"

if [ -d "$TARGET_ROOTFS_DIR" ]; then
  rm -rf $TARGET_ROOTFS_DIR
fi

mkdir -p $TARGET_ROOTFS_DIR

cd $TARGET_ROOTFS_DIR

# need to expose proc, sysfs and dev to chrooted environment,
# if not, some packages will break dpkg --configure process
echo "Setup needed devices..."
mkdir dev proc sys
mount -t proc proc proc/
mount -t sysfs sys sys/
mount -o bind /dev dev/

cd ..

echo "Create a basic rootfs contents..."
multistrap -f bergamota.conf

echo "Install Qemu..."
cp /usr/bin/qemu-aarch64-static $TARGET_ROOTFS_DIR/usr/bin

echo "Configure packages..."
LC_ALL=C LANGUAGE=C LANG=C chroot $TARGET_ROOTFS_DIR dpkg --configure -a

echo "Define password for root"
LC_ALL=C LANGUAGE=C LANG=C chroot $TARGET_ROOTFS_DIR passwd

echo "Remove Qemu..."
rm $TARGET_ROOTFS_DIR/usr/bin/qemu-aarch64-static

echo "Umount needed devices..."
umount $TARGET_ROOTFS_DIR/proc
umount $TARGET_ROOTFS_DIR/sys
umount $TARGET_ROOTFS_DIR/dev
