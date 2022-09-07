#!/usr/bin/env bash

# This script sets up a system as qemu host

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DIR" || exit
"${DIR}/../lib/sharedfuncs.sh"
bail_on_root

# Docs: https://wiki.archlinux.org/title/Virt-Manager
# TODO Die beiden Dateien wie im Link oben beschrieben ergänzen

sudo pacman -R gnome-boxes
sudo pacman -S --noconfirm virt-manager qemu-desktop libvirt edk2-ovmf dnsmasq iptables-nft

ADD_USER=$(whoami)
sudo usermod --append --groups libvirt "${ADD_USER}"
sudo systemctl enable --now libvirtd.service

# https://wiki.libvirt.org/page/Virtual_network_%22default%22_has_not_been_started
sudo virsh net-start default

echo "You should reboot now."