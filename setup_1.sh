#!/bin/bash

echo "Configuring the system"
echo
echo "---> Creating partitions to disk sda..."
parted /dev/sda mklabel msdos
parted /dev/sda mkpart primary ext4 0% 100%
mkfs.ext4 /dev/sda1

echo "---> Installing basic packages and mounting root..."
echo
mount /dev/sda1 /mnt
pacstrap -K /mnt base base-devel linux-lts linux-firmware intel-ucode nano pacman-contrib
genfstab -U /mnt >> /mnt/etc/fstab

echo
echo "---> Done!"
echo
echo "Please execute arch-chroot /mnt to continue the installation"
