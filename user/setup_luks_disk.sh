#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";cd $DIR
. ../lib/sharedfuncs.sh

bail_on_user

# vars
MOUNTPOINT="/mnt"

SYS="BIOS"

if [ -d /sys/firmware/efi ]; then
        SYS="UEFI"
fi

loadkeys de-latin1

# determine disk to install on
print_info "Available storage devices:"

lsblk -o KNAME,TYPE,SIZE,MODEL | grep disk

read -p "Disk to wipe and encrypt (for example '/dev/nvme1n1' or '/dev/sdc'): " DISK

if [[ $DISK == *"nvme"* ]]
then
    DISK_DATA="${DISK}p1"
else
    DISK_DATA="${DISK}1"
fi

# Create partition table

read -p "Set up new partition table for ${DISK}? (y/N): " NEWPARTITIONTABLE

if [[ NEWPARTITIONTABLE != "y" ]]
then
    exit 0
fi

if [ $SYS == "BIOS" ]; then
    parted --script ${DISK} mklabel msdos
else
    parted --script ${DISK} mklabel gpt
fi

# Check if there are partitions set up. If so, bail out and prompt the user to wipe them first.
print_info "Checking for existing partitions..."
lsblk ${DISK} | grep part

if [ $? -eq 0 ]; then
        echo "ERROR: Existing partitions on ${DISK} found."
        echo "Wipe them first with 'sgdisk -z ${DISK}' and try again."
        exit 1
fi

# Set only after we have checked for existing partions as that command is supposed to fail.
set -e

parted --script ${DISK} mkpart primary ext2 1MiB 100%

cryptsetup --verify-passphrase luksFormat $DISK_DATA -c aes -s 256 -h sha256
cryptsetup luksOpen $DISK_DATA luks_data
mkfs.ext4 -m0 /dev/mapper/luks_data

UUID=`cryptsetup luksUUID $DISK_DATA`
echo "luks_data UUID=${UUID} none luks" >> /etc/crypttab

mkdir -p /mnt/luks_data

echo "/dev/mapper/luks_data /mnt/luks_data ext4 defaults 0 2" >> /etc/fstab

mount /dev/mapper/luks_data /mnt/luks_data
mkdir /mnt/luks_data/re /mnt/luks_data/st

chown root:users /mnt/luks_data
chmod -R 0770 /mnt/luks_data
chmod -R u+s /mnt/luks_data
chown re:users /mnt/luks_data/re
chown st:users /mnt/luks_data/st