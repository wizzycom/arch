#!/bin/bash

echo "Configuring the system"
echo
echo "---> Setting clock, timezone and locales..."
echo
ln -sf /usr/share/zoneinfo/Europe/Athens /etc/localtime
hwclock --systohc
cp /etc/locale.gen /etc/locale.gen.backup
sed -i "/^#en_US.UTF-8 UTF-8/ cen_US.UTF-8 UTF-8" /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

echo "---> Setting hosts and hostname..."
echo
echo "storage" > /etc/hostname

tee -a /etc/hosts > /dev/null <<EOT

# The following lines are desirable for IPv4 capable hosts
127.0.0.1 localhost
127.0.1.1 storage.net.home storage

# The following lines are desirable for IPv6 capable hosts
::1 localhost
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
EOT

echo "---> Enabling multilib repo..."
echo
cp /etc/pacman.conf /etc/pacman.conf.backup
sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf

echo "---> Installing basic packages..."
echo
pacman -Syy
pacman -Sy --noconfirm --needed $(<pkg/base_server.txt)

echo "---> Creating users..."
echo
usermod --password $(echo password | openssl passwd -1 -stdin) root

sed -i "/HOOKS=(base udev autodetect modconf kms keyboard keymap consolefont block filesystems fsck)/c\HOOKS=(base udev autodetect modconf kms keyboard keymap block filesystems fsck)" /etc/mkinitcpio.conf
mkinitcpio -P

echo "---> Configuring GRUB..."
echo
grub-install --target=i386-pc /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg

echo "---> Setting swap file..."
echo
dd if=/dev/zero of=/swapfile bs=1M count=2048 status=progress
chmod 600 /swapfile
mkswap /swapfile
echo "vm.swappiness=10" > /etc/sysctl.d/99-swappiness.conf

echo "---> Adding additional entries to fstab..."
echo
echo "/swapfile none swap defaults 0 0" >> /etc/fstab

echo "---> Enabling services..."
echo

systemctl enable acpid
systemctl enable avahi-daemon
systemctl enable NetworkManager
systemctl enable sshd
systemctl enable fstrim.timer

echo
echo "---> Done!"
echo
echo "Please exit the chroot environment and REBOOT!!"
