#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";cd $DIR
. ../lib/sharedfuncs.sh

bail_on_user

# vars
MOUNTPOINT="/mnt"

loadkeys de-latin1

# determine disk to install on
print_info "Available storage devices:"

lsblk -o KNAME,TYPE,SIZE,MODEL | grep disk

read -p "Disk to install on (for example '/dev/nvme0n1' or '/dev/sda'): " DISK

if [[ $DISK == *"nvme"* ]]
then
    DISK_BOOT="${DISK}p1"
    DISK_SYSTEM="${DISK}p2"
else
    DISK_BOOT="${DISK}1"
    DISK_SYSTEM="${DISK}2"
fi

# Check if there are partitions set up. If so, bail out and prompt the user to wipe them first.
print_info "Checking for existing partitions..."
lsblk ${DISK} | grep part

if [ $? -eq 0 ]; then
        echo "ERROR: Existing partitions on ${DISK} found."
        echo "Wipe them first with 'sgdisk -z ${DISK} && reboot' and try again."
        exit 1
fi

# Set only after we have checked for existing partions as that command is supposed to fail.
set -e

# Set vars
SYS="BIOS"

if [ -d /sys/firmware/efi ]; then
        SYS="UEFI"
fi

print_info "This is a ${SYS} system."

# https://wiki.archlinux.org/index.php/Dm-crypt/Encrypting_an_entire_system#Simple_partition_layout_with_LUKS

## Prepare disks

# create 512 MiB boot partition, rest is system
print_info "Creating partitions..."
if [ $SYS == "BIOS" ]; then
        parted --script ${DISK} \
            mklabel msdos \
            mkpart primary ext2 1MiB 512MiB \
            set 1 boot on \
            mkpart primary ext4 512MiB 100%
else
        # UEFI boot should have boot flag
        parted --script ${DISK} \
            mklabel gpt \
            mkpart EF00 ext2 1MiB 512MiB \
            set 1 boot on \
            mkpart primary ext4 512MiB 100%
fi

# Create the LUKS encrypted container at the "system" partition.
print_info "Enter a passphrase for the LUKS encrypted container on ${DISK_SYSTEM}:"
cryptsetup --cipher aes-xts-plain64 --key-size 512 --hash sha512 --iter-time 5000 --use-random --verify-passphrase luksFormat ${DISK_SYSTEM}

# Open the container. After that the decrypted container will be available at /dev/mapper/lvmdisk.
print_info "Open the container. After that the decrypted container will be available at /dev/mapper/lvmdisk."
cryptsetup open --type luks ${DISK_SYSTEM} lvmdisk

## Prepare LVs

# Create a physical volume on top of the opened LUKS container:
print_info "Create a physical volume on top of the opened LUKS container:"
pvcreate /dev/mapper/lvmdisk

# Create the volume group named ${VG}, adding the previously created physical volume to it:
print_info "Create the volume group named ${VG}, adding the previously created physical volume to it..."
VG="SDOVG"
vgcreate ${VG} /dev/mapper/lvmdisk

# Create all your logical volumes on the volume group:
print_info "Create all your logical volumes on the volume group..."
lvcreate -L 500MiB ${VG} -n swaplv
lvcreate -l 40%VG ${VG} -n rootlv
lvcreate -l 100%FREE ${VG} -n homelv

# Format your filesystems on each logical volume:
print_info "Format your filesystems on each logical volume..."
mkfs.ext4 /dev/mapper/${VG}-rootlv
mkfs.ext4 /dev/mapper/${VG}-homelv
mkswap /dev/mapper/${VG}-swaplv

# Mount your filesystems:
print_info "Mount your filesystems..."
mount /dev/mapper/${VG}-rootlv /mnt
mkdir /mnt/home
mount /dev/mapper/${VG}-homelv /mnt/home
swapon /dev/mapper/${VG}-swaplv

## Prepare boot partition
print_info "Creating file systems and mounting..."
mkdir /mnt/boot
if [ $SYS == "BIOS" ]; then
        mkfs.ext2 ${DISK_BOOT} 
        mount ${DISK_BOOT}  /mnt/boot
else
        mkfs.fat -F 32 -n EFIBOOT ${DISK_BOOT} 
        mount -L EFIBOOT /mnt/boot
fi

print_info "Done."


# wget -q -O - "https://raw.githubusercontent.com/rene-s/ArchPlayground/master/bin/arch_disk.sh?1" | bash

