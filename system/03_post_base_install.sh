#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";cd $DIR
. ../lib/sharedfuncs.sh

bail_on_root

sudo systemctl enable --now dhcpcd.service
sudo systemctl enable --now fstrim.timer
sudo systemctl enable --now systemd-timesyncd.service
sudo systemctl enable --now acpid

sudo systemctl start dhcpcd.service
echo "Waiting for the network connection..."
sleep 10

TMP_DIR=`mktemp -d`
pacman -Q yay 2>/dev/null

if [ $? != "0" ]; then
	echo "Installing yay..."
	cd $TMP_DIR
	git clone https://aur.archlinux.org/yay.git
    cd yay;makepkg -si
fi

cd
rm -rf $TMP_DIR

echo "Done."
echo "Exit the shell session and continue with ./system/04_post_desktop_default_install.sh as root."


# @todo: $ sudo nano /etc/NetworkManager/NetworkManager.conf
#.
#.
#[ifupdown]
#managed=true
# Hilft dem NM, VPN-Verbindungen aufzubauen

# yay -S wireguard-lts networkmanager-wireguard-git

@todo: Add systemd timers: https://unix.stackexchange.com/a/590001