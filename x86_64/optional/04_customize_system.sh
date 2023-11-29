#!/usr/bin/env bash

# This script customizes a system for use with SDO

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DIR" || exit
. "${DIR}/../lib/sharedfuncs.sh"
bail_on_user

# Always enable parallel downloads
sed -i 's,#\?\s*ParallelDownloads\s*=\s*[0-9]\+.*,ParallelDownloads = 5,g' /etc/pacman.conf

# If there is a file /etc/bluetooth/main.conf, apply some recommended changes from Arch Wiki.
# See https://wiki.archlinux.org/title/Bluetooth_headset#A2DP_not_working_with_PulseAudio
MODIFY_FILE=/etc/bluetooth/main.conf

if [[ -f "${MODIFY_FILE}" ]]; then
  pcregrep -M "^Disable=Socket" "${MODIFY_FILE}" > /dev/null
  [[ $? -gt 0 ]] && sed -i 's,\[General\],\[General\]\nDisable=Socket,g' "${MODIFY_FILE}"

  pcregrep -M "^MultiProfile=multiple" "${MODIFY_FILE}" > /dev/null
  [[ $? -gt 0 ]] && sed -i 's,\[General\],\[General\]\nMultiProfile=multiple,g' "${MODIFY_FILE}"
fi

# Prepare for IntelliJ IDEA/PhpStorm; see https://confluence.jetbrains.com/display/IDEADEV/Inotify+Watches+Limit
MODIFY_FILE=/etc/sysctl.d/inotify.conf

if [[ ! -f "${MODIFY_FILE}" ]]; then
  touch "${MODIFY_FILE}"
fi

pcregrep -M "^fs.inotify.max_user_watches\s*=\s*[0-9]+" "${MODIFY_FILE}" > /dev/null
[[ $? -gt 0 ]] && echo "fs.inotify.max_user_watches = 524289" >> "${MODIFY_FILE}"

# Set wtnet mirror
#MIRROR_FILE=/etc/pacman.d/mirrorlist
#
#if [[ -f "${MIRROR_FILE}" ]]; then
#  mv "${MIRROR_FILE}" "${MIRROR_FILE}.archplayground"
#  echo "Server = https://mirror.wtnet.de/archlinux/\$repo/os/\$arch" > "${MIRROR_FILE}"
#  chown root:root "${MIRROR_FILE}"
#  chmod 0644 "${MIRROR_FILE}"
#fi

# Make make use all available CPU cores
MODIFY_FILE=/etc/makepkg.conf
pcregrep -M "^MAKEFLAGS=\"-j\\$\(nproc\)\"" "${MODIFY_FILE}" > /dev/null
[[ $? -gt 0 ]] && echo "MAKEFLAGS=\"-j\$(nproc)\"" >> "${MODIFY_FILE}"

# Frame.work-specific stuff
# https://guides.frame.work/Guide/Ubuntu+22.04+LTS+Installation+on+the+Framework+Laptop/109
echo "options snd-hda-intel model=dell-headset-multi" > /etc/modprobe.d/alsa-base.conf

grep -e "^GRUB_CMDLINE_LINUX_DEFAULT=\".*nvme.noacpi=1" /etc/default/grub 1>/dev/null
if [[ $? -gt 0 ]]; then
  sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT="/GRUB_CMDLINE_LINUX_DEFAULT="nvme.noacpi=1 /g' /etc/default/grub
  grub-mkconfig -o /boot/grub/grub.cfg
fi

# Change default OOM behaviour.
# FFS WHY??? With the defaults the system gets unresponsive in low-memory conditions, for example when running
# >2 local LLM queries at the same time. I am still experimenting with it though.
# See https://wiki.archlinux.org/title/Improving_performance for reference.
# Note: Instead of the system getting unresponsive, processes might crash instead, possibly leading to data loss.
# But at least we can continue using the freaking system.
add_line_to_file "echo 75 > /proc/sys/vm/overcommit_ratio" /etc/sysctl.d/99-archplayground.conf
add_line_to_file "echo 2 > /proc/sys/vm/overcommit_memory" /etc/sysctl.d/99-archplayground.conf
