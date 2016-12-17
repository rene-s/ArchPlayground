#!/usr/bin/env bash

. ./sharedfuncs.sh

# vars
MOUNTPOINT="/mnt"
DISK="/dev/sda"
DISK_BOOT="${DISK}1"
DISK_SYSTEM="${DISK}2"

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
echo "Update time";
timedatectl set-ntp true

# Bootstrap Arch
echo "Bootstrapping"
pacstrap /mnt base

# Generate fstab
echo "Generating fstab"
genfstab -U /mnt >> /mnt/etc/fstab

# Chroot into new env
echo "Chrooting..."
arch-chroot /mnt

# Install Intel microcode
echo "Install Intel microcode..."
pacman -S --noconfirm intel-ucode syslinux grub

# Update timezone and system time
echo "Setting time and time zones..."
ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime
hwclock --systohc

# Setup locales and keymap
echo "Setup locales and keymap..."
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
echo "de_DE@euro ISO-8859-15" >> /etc/locale.gen
echo "de_DE.UTF-8 UTF-8" >> /etc/locale.gen

echo "LANG=de_DE.UTF-8" > /etc/locale.conf
echo "KEYMAP=de-latin1-nodeadkeys" > /etc/vconsole.conf

# Basic network setup
echo "Basic network setup..."
HOSTNAME="sdotestsystem"
echo "${HOSTNAME}" > /etc/hostname
echo "127.0.0.1 localhost.localdomain localhost" > /etc/hosts
echo "::1 localhost.localdomain localhost" >> /etc/hosts
echo "127.0.1.1 ${HOSTNAME}.localdomain ${HOSTNAME}" >> /etc/hosts

# Install boot loader
echo "Install boot loader..."
mkdir /boot/syslinux
extlinux --install /boot/syslinux
cat /usr/lib/syslinux/bios/mbr.bin > "${DISK}"
cp /usr/lib/syslinux/bios/libcom32.c32 /usr/lib/syslinux/bios/menu.c32 /usr/lib/syslinux/bios/libutil.c32 /boot/syslinux/

#pacstrap / grub os-prober

#if [ $SYS == "UEFI" ]; then
#    pacstrap / efibootmgr dosfstools
#fi

# Setup /etc/mkinitcpio.conf; add "encrypt" and "lvm" hooks
sed -i -- "s/^HOOKS=/#HOOKS=/g" /etc/mkinitcpio.conf
echo 'HOOKS="base udev autodetect modconf block encrypt lvm2 filesystems keyboard fsck"' >> /etc/mkinitcpio.conf

#If you use encryption LUKS change the APPEND line to use your encrypted volume:
SYSTEM_UUID=`blkid -s UUID -o value "${DISK_SYSTEM}"`
echo "Found UUID ${SYSTEM_UUID} for disk ${DISK_SYSTEM}!"
#echo "#APPEND root=/dev/mapper/SDOVG-rootlv cryptdevice=UUID="${SYSTEM_UUID}":lvm rw" >> /boot/syslinux/syslinux.cfg

mkinitcpio -p linux

# Finish
echo "Done."
echo "Set a password with 'passwd',"
echo "then exit chroot and reboot with 'umount -R /mnt && reboot'"
echo "Do not forget to remove installation media!"

