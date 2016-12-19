#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cd $DIR

. ./sharedfuncs.sh

# vars
MOUNTPOINT="/mnt"
DISK="/dev/sda"
DISK_BOOT="${DISK}1"
DISK_SYSTEM="${DISK}2"

set -e
loadkeys de-latin1

# Set vars
SYS="BIOS"

if [ -d /sys/firmware/efi ]; then
        SYS="UEFI"
fi

print_info "This is a ${SYS} system."

# Bootstrap Arch
print_info "Bootstrapping"
pacstrap /mnt base base-devel parted btrfs-progs f2fs-tools ntp

# Update time
print_info "Update time";
timedatectl set-ntp true

# Generate fstab
print_info "Generating fstab"
genfstab -U /mnt >> /mnt/etc/fstab

# Chroot into new env
print_info "Chrooting..."

# Install Intel microcode
print_info "Install Intel microcode..."
arch_chroot "pacman -S --noconfirm intel-ucode syslinux grub"

# Update timezone and system time
print_info "Setting time and time zones..."
ln -sf /mnt/usr/share/zoneinfo/Europe/Berlin /mnt/etc/localtime
hwclock --systohc

# Setup locales and keymap
print_info "Setup locales and keymap..."
echo "en_US.UTF-8 UTF-8" > /mnt/etc/locale.gen
echo "de_DE@euro ISO-8859-15" >> /mnt/etc/locale.gen
echo "de_DE.UTF-8 UTF-8" >> /mnt/etc/locale.gen

echo "LANG=de_DE.UTF-8" > /mnt/etc/locale.conf
echo "KEYMAP=de-latin1" > /mnt/etc/vconsole.conf

# Basic network setup
print_info "Basic network setup..."
HOSTNAME="sdotestsystem"
echo "${HOSTNAME}" >/mnt/etc/hostname
echo "127.0.0.1 localhost.localdomain localhost" >/mnt/etc/hosts
echo "::1 localhost.localdomain localhost" >>/mnt/etc/hosts
echo "127.0.1.1 ${HOSTNAME}.localdomain ${HOSTNAME}" >>/mnt/etc/hosts

# Install boot loader
print_info "Install boot loader..."
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
echo 'HOOKS="base udev autodetect modconf block encrypt lvm2 filesystems keyboard fsck"' >>/mnt/etc/mkinitcpio.conf

#If you use encryption LUKS change the APPEND line to use your encrypted volume:
SYSTEM_UUID=`blkid -s UUID -o value "${DISK_SYSTEM}"`
print_info "Found UUID ${SYSTEM_UUID} for disk ${DISK_SYSTEM}!"

# Create SysLinux config
CFG_SYSLINUX=/mnt/boot/syslinux/syslinux.cfg

echo "" >> $CFG_SYSLINUX
echo "LABEL Schmidt_DevOps_Arch" >> $CFG_SYSLINUX
echo "    MENU LABEL Schmidt_DevOps_Arch" >> $CFG_SYSLINUX
echo "    LINUX ../vmlinuz-linux" >> $CFG_SYSLINUX
echo "    APPEND root=/dev/mapper/SDOVG-rootlv cryptdevice=UUID="${SYSTEM_UUID}":lvm rw" >> $CFG_SYSLINUX
echo "    INITRD ../initramfs-linux.img" >> $CFG_SYSLINUX

sed -i -- "s/^DEFAULT arch/DEFAULT Schmidt_DevOps_Arch/g" $CFG_SYSLINUX

arch_chroot "mkinitcpio -p linux"

# Set up root user
print_info "Set up users:"

arch_chroot "pacman -S --noconfirm zsh"
arch_chroot "useradd -m re"
arch_chroot "useradd -m st"

configure_existing_user 'root'
configure_existing_user 're'
configure_existing_user 'st'

# Set up /etc/issue
echo "Schmidt DevOps \r (\l) -- setup on: "`date` > /mnt/etc/issue

# Setup network
print_info "Setup network..."
configure_network

# Finish
print_info "Done."

# @todo: add user (steffi|rene)
# @todo: install desktop