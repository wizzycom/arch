#!/bin/bash

echo "Configuring the system"
echo
echo "---> Installing YAY..."
echo
cd ~
git clone https://aur.archlinux.org/yay-git.git
cd yay-git/
makepkg -si
echo
echo "---> Installing YAY packages..."
yay -S --noconfirm --needed $(<pkg/aur.txt)
echo
echo "---> Done!"
