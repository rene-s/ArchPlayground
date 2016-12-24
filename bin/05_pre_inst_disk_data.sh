#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cd $DIR

. ./sharedfuncs.sh

if [ "${USER}" != "root" ]; then
    print_danger "This script is supposed to be run as root, not as user."
    exit 1
fi

# vars
MOUNTPOINT="/mnt"

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

KEY="/etc/luks_data.key"

if [[ -f ${KEY} ]]
then
    print_danger "LUKS key file ${KEY} already exists. If you wish to recreate it, delete it manually and try again."
    exit 1
fi

dd bs=512 count=4 if=/dev/urandom of=${KEY}
chown root:root ${KEY}
chmod 0600 ${KEY}

parted --script ${DISK} \
    mkpart primary ext2 1MiB 100%

cryptsetup luksAddKey $DISK_DATA ${KEY}
cryptsetup -c aes -s 256 -h sha256 luksFormat $DISK_DATA ${KEY}
cryptsetup luksOpen $DISK_DATA luks_data --key-file ${KEY}
mkfs.ext4 -m0 /dev/mapper/luks_data # block size 1024 bytes, no space reserved for root

UUID=`cryptsetup luksUUID $DISK_DATA`
echo "luks_data UUID=${UUID} ${KEY} luks" >> /etc/crypttab

mkdir /mnt/luks_data

echo "/dev/mapper/luks_data /mnt/luks_data ext4 defaults 0 2" >> /etc/fstab

mount /dev/mapper/luks_data /mnt/luks_data
mkdir /mnt/luks_data/re /mnt/luks_data/st

chown re:users /mnt/luks_data/re
chown st:users /mnt/luks_data/st
chmod -R 0700 /mnt/luks_data
chmod -R u+s /mnt/luks_data