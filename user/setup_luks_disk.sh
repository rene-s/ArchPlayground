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

read -p "Disk to wipe and encrypt (for example '/dev/nvme1n1' or '/dev/sdc'): " DISK

if [[ $DISK == *"nvme"* ]]
then
    DISK_DATA="${DISK}p1"
else
    DISK_DATA="${DISK}1"
fi

# Calculate optimal start block (check with ```parted ${DISK}``` and then ```align-check optimal 1```
IFS='/' read -ra disk_name <<< "$DISK"

optimal_io_size=`cat /sys/block/${disk_name[2]}/queue/optimal_io_size`
alignment_offset=`cat /sys/block/${disk_name[2]}/alignment_offset`
physical_block_size=`cat /sys/block/${disk_name[2]}/queue/physical_block_size`

sum=$((optimal_io_size+alignment_offset))
start_block=0

if [ $sum -gt 0 ] && [ $physical_block_size -gt 0 ]; then
	start_block=$(((optimal_io_size+alignment_offset)/physical_block_size))
fi

echo "Using optimal start block ${start_block}!"

# Decide whether to use static key files or not
USE_STATIC_KEY_FILES="n"
STATIC_KEY_FILE=""

read -p "Use static key file for ${DISK}? (y/N): " ANSWER

if [[ $ANSWER == "y" ]]
then
    USE_STATIC_KEY_FILES="y"
    STATIC_KEY_FILE="/etc/luks_static_key_"`uuidgen`
    touch $STATIC_KEY_FILE
    chmod 0600 $STATIC_KEY_FILE
    dd bs=512 count=4 if=/dev/urandom of=$STATIC_KEY_FILE
fi

# Create partition table

read -p "Set up new partition table for ${DISK}? (y/N): " NEW_PARTITION_TABLE

if [[ $NEW_PARTITION_TABLE != "y" ]]
then
    exit 0
fi

parted --script ${DISK} mklabel gpt

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

parted --script ${DISK} mkpart primary ${start_block} 100%

if [[ $USE_STATIC_KEY_FILES == "y" ]]; then
	cryptsetup luksFormat $DISK_DATA $STATIC_KEY_FILE
	cryptsetup luksOpen $DISK_DATA luks_data --key-file $STATIC_KEY_FILE
else
	cryptsetup --verify-passphrase luksFormat $DISK_DATA -c aes -s 256 -h sha256
	cryptsetup luksOpen $DISK_DATA luks_data
fi

mkfs.ext4 -m0 /dev/mapper/luks_data

UUID=`cryptsetup luksUUID $DISK_DATA`

if [[ $USE_STATIC_KEY_FILES == "y" ]]; then
	echo "luks_data UUID=${UUID} ${STATIC_KEY_FILE}" >> /etc/crypttab
else
	echo "luks_data UUID=${UUID} none luks" >> /etc/crypttab
fi

mkdir -p /mnt/luks_data

echo "/dev/mapper/luks_data /mnt/luks_data ext4 defaults 0 2" >> /etc/fstab

mount /dev/mapper/luks_data /mnt/luks_data
mkdir /mnt/luks_data/re /mnt/luks_data/st

chown root:users /mnt/luks_data
chmod -R 0770 /mnt/luks_data
chmod -R u+s /mnt/luks_data
chown re:users /mnt/luks_data/re
chown st:users /mnt/luks_data/st