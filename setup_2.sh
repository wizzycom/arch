#!/bin/bash

echo "Configuring the system"
echo
echo "---> Setting clock, timezone and locales..."
echo
ln -sf /usr/share/zoneinfo/Europe/Athens /etc/localtime
hwclock --systohc
cp /etc/locale.gen /etc/locale.gen.backup
sed -i "/^#en_US.UTF-8 UTF-8/ cen_US.UTF-8 UTF-8" /etc/locale.gen
sed -i "/^#el_GR.UTF-8 UTF-8/ cel_GR.UTF-8 UTF-8" /etc/locale.gen
sed -i "/^#cy_GB.UTF-8 UTF-8/ ccy_GB.UTF-8 UTF-8" /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "KEYMAP=us" >> /etc/vconsole.conf
echo "FONT=eurlatgr" >> /etc/vconsole.conf

echo "---> Setting hosts and hostname..."
echo
echo "client-one" > /etc/hostname

tee -a /etc/hosts > /dev/null <<EOT

# The following lines are desirable for IPv4 capable hosts
127.0.0.1 localhost
127.0.1.1 client-one.net.home client-one

# The following lines are desirable for IPv6 capable hosts
::1 localhost
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
EOT

echo "---> Enabling multilib repo..."
echo
cp /etc/pacman.conf /etc/pacman.conf.backup
sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf

echo "---> Setting environmental variables..."
echo
echo "LC_ALL=en_US.UTF-8" >> /etc/environment

echo "---> Installing basic packages..."
echo
pacman -Syy
pacman -Sy --noconfirm $(<pkg/base.txt)
pacman -Sy --noconfirm $(<pkg/sound.txt)
pacman -Sy --noconfirm $(<pkg/video.txt)


echo "---> Creating users..."
echo
useradd -m -G wheel wizzy
usermod --password $(echo password | openssl passwd -1 -stdin) wizzy
usermod --password $(echo password | openssl passwd -1 -stdin) root

echo "## User privilege specification" >> /etc/sudoers.d/users
echo "## Uncomment to allow members of group wheel to execute any command" >> /etc/sudoers.d/users
echo "%wheel ALL=(ALL:ALL) ALL" >> /etc/sudoers.d/users

echo "---> Setting AMD graphics..."
echo
echo "options amdgpu si_support=1" > /etc/modprobe.d/amdgpu.conf 
echo "options amdgpu cik_support=0" >> /etc/modprobe.d/amdgpu.conf 
echo "blacklist radeon" > /etc/modprobe.d/radeon.conf 
cp /etc/mkinitcpio.conf /etc/mkinitcpio.conf.backup
sed -i "/MODULES=()/c\MODULES=(amdgpu radeon)" /etc/mkinitcpio.conf
sed -i "/BINARIES=()/c\BINARIES=(setfont)" /etc/mkinitcpio.conf
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
echo "/swapfile none swap defaults 0 0" >> /etc/fstab

echo "---> Installing KDE packages..."
echo
pacman -Sy --needed --noconfirm $(<pkg/KDE.txt)

echo "---> Enabling services..."
echo
systemctl enable sddm.service
systemctl enable acpid
systemctl enable avahi-daemon
systemctl enable bluetooth
systemctl enable cups.service
systemctl enable NetworkManager
systemctl enable sshd
systemctl enable fstrim.timer

echo
echo "---> Done!"
echo
echo "Please exit the chroot environment and REBOOT!!"

