#!/usr/bin/env bash

# This script installs a LTS Linux kernel.

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";cd $DIR
. ../lib/sharedfuncs.sh

bail_on_user

pacman -Q linux 2>/dev/null
LINUX_INSTALLED=$?

pacman -Q linux-lts 2>/dev/null
LINUX_LTS_INSTALLED=$?

if [[ $LINUX_INSTALLED != "0" ]] && [[ $LINUX_LTS_INSTALLED == "0" ]]; then
	print_info "Linux LTS is already installed."
	exit 1
fi

pacman -S --noconfirm linux-lts linux-lts-headers

pacman -Q linux-lts 2>/dev/null
LINUX_LTS_INSTALLED=$?

if [[ $LINUX_LTS_INSTALLED != "0" ]]; then
	print_info "Linux LTS not successfully installed."
	exit 1
fi

pacman -Q virtualbox-guest-modules-arch 2> /dev/null && pacman -R --noconfirm virtualbox-guest-modules-arch
pacman -R linux

SYS="BIOS"

if [ -d /sys/firmware/efi ]; then
	SYS="UEFI"
fi

if [ $SYS == "UEFI" ]; then
	grub-mkconfig -o /boot/grub/grub.cfg
else
	CFG_SYSLINUX=/boot/syslinux/syslinux.cfg
	
	if [ -f $CFG_SYSLINUX ] && [ -f /boot/vmlinuz-linux-lts ] && [ -f /boot/initramfs-linux-lts.img ]; then
		sed -i '/vmlinuz-linux-lts/! s/vmlinuz-linux/vmlinuz-linux-lts/g' $CFG_SYSLINUX	
		sed -i '/initramfs-linux-lts/! s/initramfs-linux/initramfs-linux-lts/g' $CFG_SYSLINUX
	else
		print_danger "Error, required files not found."
		exit 1
	fi
fi	

echo "Done."

