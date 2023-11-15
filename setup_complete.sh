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
pacstrap -K /mnt base base-devel linux-lts linux-firmware intel-ucode nano pacman-contrib git
genfstab -U /mnt >> /mnt/etc/fstab

echo "---> Setting clock, timezone and locales..."
echo
arch-chroot /mnt ln -sf /usr/share/zoneinfo/Europe/Athens /etc/localtime
hwclock --systohc
arch-chroot /mnt cp /etc/locale.gen /etc/locale.gen.backup
sed -i "/^#en_US.UTF-8 UTF-8/ cen_US.UTF-8 UTF-8" /mnt/etc/locale.gen
sed -i "/^#el_GR.UTF-8 UTF-8/ cel_GR.UTF-8 UTF-8" /mnt/etc/locale.gen
sed -i "/^#cy_GB.UTF-8 UTF-8/ ccy_GB.UTF-8 UTF-8" /mnt/etc/locale.gen
arch-chroot /mnt locale-gen
echo "LANG=en_US.UTF-8" > /mnt/etc/locale.conf
arch-chroot /mnt export LANG=en_US.UTF-8
