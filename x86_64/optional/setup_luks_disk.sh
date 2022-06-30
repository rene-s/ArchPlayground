#!/usr/bin/env bash

# This script sets up an encrypted secondary disk and configures mounting it at boot time.

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DIR" || exit
. ../lib/sharedfuncs.sh

bail_on_user

pacman -Q parted dialog 2>/dev/null || pacman -S --noconfirm parted dialog

# determine disk to install on
echo "Available storage devices:"

lsblk -o KNAME,TYPE,SIZE,MODEL | grep disk

read -r -p "Disk to wipe and encrypt (for example '/dev/nvme1n1' or '/dev/sdc'): " DISK

if [[ $DISK == *"nvme"* ]]; then
  DISK_DATA="${DISK}p1"
else
  DISK_DATA="${DISK}1"
fi

# Calculate optimal start block (check with ```parted ${DISK}``` and then ```align-check optimal 1```
IFS='/' read -ra disk_name <<<"$DISK"

optimal_io_size=$(cat "/sys/block/${disk_name[2]}/queue/optimal_io_size")
alignment_offset=$(cat "/sys/block/${disk_name[2]}/alignment_offset")
physical_block_size=$(cat "/sys/block/${disk_name[2]}/queue/physical_block_size")

sum=$((optimal_io_size + alignment_offset))
start_block=0

read -r -p "Want me to automatically try to calculate partition alignment for ${DISK}? (y/N): " ANSWER

if [[ $ANSWER == "y" ]]; then
  if [ $sum -gt 0 ] && [ "$physical_block_size" -gt 0 ]; then
    start_block=$(((optimal_io_size + alignment_offset) / physical_block_size))
  fi
  echo "Using optimal start block ${start_block}!"
fi

# Decide whether to use static key files or not
USE_STATIC_KEY_FILES="n"
STATIC_KEY_FILE=""

read -r -p "Use static key file for ${DISK}? (y/N): " ANSWER

if [[ $ANSWER == "y" ]]; then
  USE_STATIC_KEY_FILES="y"
  mkdir -p /etc/cryptsetup-keys.d
  STATIC_KEY_FILE="/etc/cryptsetup-keys.d/$(uuidgen).key"
  touch "$STATIC_KEY_FILE"
  chmod 0600 "$STATIC_KEY_FILE"
  dd bs=256 count=1 if=/dev/urandom of="$STATIC_KEY_FILE"
fi

# Create partition table

read -r -p "Set up new partition table for ${DISK}? (y/N): " NEW_PARTITION_TABLE

if [[ $NEW_PARTITION_TABLE != "y" ]]; then
  exit 0
fi

parted --script "${DISK}" mklabel gpt

# Check if there are partitions set up. If so, bail out and prompt the user to wipe them first.
echo "Checking for existing partitions..."
lsblk "${DISK}" | grep part
RET=$?

if [ $RET -eq 0 ]; then
  echo "ERROR: Existing partitions on ${DISK} found."
  echo "Wipe them first with 'sgdisk -z ${DISK}' and try again."
  exit 1
fi

# Set only after we have checked for existing partitions as that command is supposed to fail.
set -e

if [ $start_block -gt 0 ]; then
  parted --script "${DISK}" mkpart primary ${start_block} 100%
else
  parted --script "${DISK}" mkpart primary ext2 0% 100%
fi

if [[ $USE_STATIC_KEY_FILES == "y" ]]; then
  cryptsetup luksFormat "$DISK_DATA" "$STATIC_KEY_FILE"
  cryptsetup luksOpen "$DISK_DATA" luks_data --key-file "$STATIC_KEY_FILE"
else
  cryptsetup --verify-passphrase luksFormat "$DISK_DATA" -c aes -s 256 -h sha256
  cryptsetup luksOpen "$DISK_DATA" luks_data
fi

FS="ext4"

answer=""
question="Use f2fs instead of ext4? (y/N)"
ask "Change default FS" "Change default FS" "$question" "n"
if [[ $answer == "y" ]]; then
  FS=f2fs
  mkfs.f2fs /dev/mapper/luks_data
else
  mkfs.ext4 -m0 /dev/mapper/luks_data
fi

UUID=$(cryptsetup luksUUID "$DISK_DATA")

if [[ $USE_STATIC_KEY_FILES == "y" ]]; then
  echo "luks_data UUID=${UUID} ${STATIC_KEY_FILE} luks,size=256,cipher=aes-xts-plain64,timeout=180" >>/etc/crypttab
else
  echo "luks_data UUID=${UUID} none luks,size=256,cipher=aes-xts-plain64,timeout=180" >>/etc/crypttab
fi

mkdir -p /mnt/luks_data

echo "/dev/mapper/luks_data /mnt/luks_data $FS defaults 0 2" >>/etc/fstab
systemctl daemon-reload

mount /dev/mapper/luks_data /mnt/luks_data

chown root:users /mnt/luks_data
chmod -R 0770 /mnt/luks_data
chmod -R u+s /mnt/luks_data

getent passwd re
RET=$?

if [[ $RET == "0" ]]; then
  mkdir -p /mnt/luks_data/re
  chown re:users /mnt/luks_data/re
fi

getent passwd st
RET=$?

if [[ $RET == "0" ]]; then
  mkdir -p /mnt/luks_data/st
  chown st:users /mnt/luks_data/st
fi
