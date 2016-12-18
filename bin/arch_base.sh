#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cd $DIR

. ./sharedfuncs.sh

# vars
MOUNTPOINT="/mnt"
DISK="/dev/sda"
DISK_BOOT="${DISK}1"
DISK_SYSTEM="${DISK}2"

print_line "DO NOT USE, THIS IS WORK IN PROGRESS AND WILL DESTROY ALL YOUR DATA"

print_line ""
print_line "Please wait..."

set -e
loadkeys de-latin1-nodeadkeys

# Set vars
SYS="BIOS"

if [ -d /sys/firmware/efi ]; then
        SYS="UEFI"
fi

print_line "This is a ${SYS} system."

# Update time
print_line "Update time";
timedatectl set-ntp true

# Bootstrap Arch
print_line "Bootstrapping"
pacstrap /mnt base

# Generate fstab
print_line "Generating fstab"
genfstab -U /mnt >> /mnt/etc/fstab

# Chroot into new env
print_line "Chrooting..."

# Install Intel microcode
print_line "Install Intel microcode..."
arch_chroot "pacman -S --noconfirm intel-ucode syslinux grub"

# Update timezone and system time
print_line "Setting time and time zones..."
ln -sf /mnt/usr/share/zoneinfo/Europe/Berlin /mnt/etc/localtime
hwclock --systohc

# Setup locales and keymap
print_line "Setup locales and keymap..."
print_line "en_US.UTF-8 UTF-8" > /mnt/etc/locale.gen
print_line "de_DE@euro ISO-8859-15" >> /mnt/etc/locale.gen
print_line "de_DE.UTF-8 UTF-8" >> /mnt/etc/locale.gen

print_line "LANG=de_DE.UTF-8" > /mnt/etc/locale.conf
print_line "KEYMAP=de-latin1-nodeadkeys" > /mnt/etc/vconsole.conf

# Basic network setup
print_line "Basic network setup..."
HOSTNAME="sdotestsystem"
print_line "${HOSTNAME}" >/mnt/etc/hostname
print_line "127.0.0.1 localhost.localdomain localhost" >/mnt/etc/hosts
print_line "::1 localhost.localdomain localhost" >>/mnt/etc/hosts
print_line "127.0.1.1 ${HOSTNAME}.localdomain ${HOSTNAME}" >>/mnt/etc/hosts

# Install boot loader
print_line "Install boot loader..."
mkdir -p /mnt/boot/syslinux
arch_chroot "extlinux --install /boot/syslinux"
cat /mnt/usr/lib/syslinux/bios/mbr.bin > "${DISK}"
cp /mnt/usr/lib/syslinux/bios/libcom32.c32 /mnt/usr/lib/syslinux/bios/menu.c32 /mnt/usr/lib/syslinux/bios/libutil.c32 /mnt/boot/syslinux/

#pacstrap / grub os-prober

#if [ $SYS == "UEFI" ]; then
#    pacstrap / efibootmgr dosfstools
#fi

# Setup/mnt/etc/mkinitcpio.conf; add "encrypt" and "lvm" hooks
sed -i -- "s/^HOOKS=/#HOOKS=/g" /mnt/etc/mkinitcpio.conf
print_line 'HOOKS="base udev autodetect modconf block encrypt lvm2 filesystems keyboard fsck"' >>/mnt/etc/mkinitcpio.conf

#If you use encryption LUKS change the APPEND line to use your encrypted volume:
SYSTEM_UUID=`blkid -s UUID -o value "${DISK_SYSTEM}"`
print_line "Found UUID ${SYSTEM_UUID} for disk ${DISK_SYSTEM}!"

# Create SysLinux config
CFG_SYSLINUX=/mnt/boot/syslinux/syslinux.cfg

print_line "" >> $CFG_SYSLINUX
print_line "LABEL Schmidt_DevOps_Arch" >> $CFG_SYSLINUX
print_line "    MENU LABEL Schmidt_DevOps_Arch" >> $CFG_SYSLINUX
print_line "    LINUX ../vmlinuz-linux" >> $CFG_SYSLINUX
print_line "    APPEND root=/dev/mapper/SDOVG-rootlv cryptdevice=UUID="${SYSTEM_UUID}":lvm rw" >> $CFG_SYSLINUX
print_line "    INITRD ../initramfs-linux.img" >> $CFG_SYSLINUX

sed -i -- "s/^DEFAULT arch/DEFAULT Schmidt_DevOps_Arch/g" $CFG_SYSLINUX

arch_chroot "mkinitcpio -p linux"

# Set up root password
print_line "Set up root password:"
arch_chroot "passwd"

# Set up /etc/issue
print_line "Schmidt DevOps \r (\l) -- setup run on: "`date` > /mnt/etc/issue

# Finish
print_line "Done."

