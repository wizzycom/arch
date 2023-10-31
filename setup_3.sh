#!/bin/bash

echo "Configuring the system"
echo
echo "---> Installing YAY"
echo
cd ~
git clone https://aur.archlinux.org/yay-git.git
cd yay-git/
makepkg -si
cd ~
echo "---> Installing AUR packages"
echo
yay -Sy --needed --noconfirm $(<pkg/aur.txt)
echo
echo "---> Done!"
echo
