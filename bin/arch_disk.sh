#!/usr/bin/env bash

echo "DO NOT USE, THIS IS WORK IN PROGRESS AND WILL DESTROY ALL YOUR DATA"

echo "This script creates a simple 'LVM on LUKS' disk setup with a"
echo "- /boot partition (ext2 on BIOS, fat32 on UEFI), a"
echo "- /root volume spanning 25% of the available disk space, and a"
echo "- /home volume spanning the rest of the disk."
echo ""
echo "Please wait..."

loadkeys de-latin1-nodeadkeys

# Check if there are partitions set up. If so, bail out and prompt the user to wipe them first.
parted --script /dev/sda print

if [ $? -eq 0 ]; then
        echo "ERROR: Existing partitions on /dev/sda found."
        echo "Wipe them first with 'sgdisk -z /dev/sda && reboot' and try again."
        exit 1
fi

# Set only after we have checked for existing partions as that command is supposed to fail.
set -e

# Set vars
SYS="BIOS"

if [ -d /sys/firmware/efi ]; then
        SYS="UEFI"
fi

echo "This is a ${SYS} system."

# https://wiki.archlinux.org/index.php/Dm-crypt/Encrypting_an_entire_system#Simple_partition_layout_with_LUKS

## Prepare disks

# create 512 MiB boot partition, rest is system

if [ $SYS == "BIOS" ]; then
        parted --script /dev/sda \
            mklabel gpt \
            mkpart EF02 1MiB 512MiB \
            mkpart primary 512MiB 100% \
            set 1 bios_grub on
else
        # UEFI boot should have boot flag
        parted --script /dev/sda \
            mklabel gpt \
            mkpart EF00 1MiB 512MiB \
            mkpart primary 512MiB 100% \
            set 1 boot on

fi

# Create the LUKS encrypted container at the "system" partition.
keyfile=/tmp/insecure-password.key
echo "insecure-password" > $keyfile
cryptsetup luksFormat /dev/sda2 $keyfile

# Open the container. After that the decrypted container will be available at /dev/mapper/lvmdisk.
cryptsetup open --type luks /dev/sda2 lvmdisk --key-file $keyfile

## Prepare LVs

# Create a physical volume on top of the opened LUKS container:
pvcreate /dev/mapper/lvmdisk

# Create the volume group named ${VG}, adding the previously created physical volume to it:
VG="SDOVG"
vgcreate ${VG} /dev/mapper/lvmdisk

# Create all your logical volumes on the volume group:
lvcreate -L 500MiB ${VG} -n swaplv
lvcreate -l 25%VG ${VG} -n rootlv
lvcreate -l 100%FREE ${VG} -n homelv

# Format your filesystems on each logical volume:
mkfs.ext4 /dev/mapper/${VG}-rootlv
mkfs.ext4 /dev/mapper/${VG}-homelv
mkswap /dev/mapper/${VG}-swaplv

# Mount your filesystems:
mount /dev/mapper/${VG}-rootlv /mnt
mkdir /mnt/home
mount /dev/mapper/${VG}-homelv /mnt/home
swapon /dev/mapper/${VG}-swaplv

## Prepare boot partition

mkdir /mnt/boot

if [ $SYS == "BIOS" ]; then
        mkfs.ext2 /dev/sda1
        mount /dev/sda1 /mnt/boot
else
        mkfs.fat -F 32 -n EFIBOOT /dev/sda1
        mount -L EFIBOOT /mnt/boot
fi

echo "Done."
