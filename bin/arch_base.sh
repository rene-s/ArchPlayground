#!/usr/bin/env bash

echo "DO NOT USE, THIS IS WORK IN PROGRESS AND WILL DESTROY ALL YOUR DATA"

echo ""
echo "Please wait..."

set -e
loadkeys de-latin1-nodeadkeys

# Set vars
SYS="BIOS"

if [ -d /sys/firmware/efi ]; then
        SYS="UEFI"
fi

echo "This is a ${SYS} system."

# Update time
timedatectl set-ntp true

# Bootstrap Arch
pacstrap /mnt base

# Generate fstab
genfstab -U /mnt >> /mnt/etc/fstab

# Chroot into new env
arch-chroot /mnt

# Install Intel microcode
pacman -S --noconfirm intel-ucode grub

# Update timezone and system time
ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime
hwclock --systohc

# Setup locales and keymap
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
echo "de_DE@euro ISO-8859-15" >> /etc/locale.gen
echo "de_DE.UTF-8 UTF-8" >> /etc/locale.gen

echo "LANG=de_DE.UTF-8" > /etc/locale.conf
echo "KEYMAP=de-latin1-nodeadkeys" > /etc/vconsole.conf

# Basic network setup
HOSTNAME="sdotestsystem"
echo "${HOSTNAME}" > /etc/hostname
echo "127.0.0.1 localhost.localdomain localhost" > /etc/hosts
echo "::1 localhost.localdomain localhost" >> /etc/hosts
echo "127.0.1.1 ${HOSTNAME}.localdomain ${HOSTNAME}" >> /etc/hosts

# Install boot loader
grub-install --target=i386-pc /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg

# Finish
echo "Done."
echo "Set a password with 'passwd',"
echo "then exit chroot and reboot with 'umount -R /mnt && reboot'"
echo "Do not forget to remove installation media!"

