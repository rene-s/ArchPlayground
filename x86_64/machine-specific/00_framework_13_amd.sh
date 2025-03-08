#!/bin/bash

# https://wiki.archlinux.org/title/Framework_Laptop_13
# https://wiki.archlinux.org/title/Framework_Laptop_13_(AMD_Ryzen_7040_Series)
# https://github.com/FrameworkComputer/linux-docs/blob/main/ubuntu-22.04-amd-fw13.md
# https://github.com/FrameworkComputer/linux-docs/blob/main/Ubuntu24.04LTS-Setup-amd-fw13.md
# https://github.com/FrameworkComputer/linux-docs/blob/main/Fedora39-amd-fw13.md
# https://github.com/FrameworkComputer/linux-docs/blob/main/framework13/Fedora41-amd-fw13.md

# https://github.com/FrameworkComputer/linux-docs/blob/main/hibernation/kernel-6-11-workarounds/suspend-hibernate-bluetooth-workaround.md#workaround-for-suspendhibernate-black-screen-on-resume-kernel-611
# https://raw.githubusercontent.com/FrameworkComputer/linux-docs/refs/heads/main/hibernation/kernel-6-11-workarounds/rfkill-suspender.sh

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DIR" || exit
. "${DIR}/../lib/sharedfuncs.sh"
bail_on_user

PRODUCT_NAME=$(dmidecode -s system-manufacturer)

if [[ "${PRODUCT_NAME}" != "Framework" ]]; then
    echo "This does not seem to be a Framework laptop, but '${PRODUCT_NAME}'."
    exit 0
fi

systemctl disable --now tlp 
pacman -R tlp
pacman -S power-profiles-daemon
systemctl enable --now power-profiles-daemon

curl -s https://raw.githubusercontent.com/FrameworkComputer/linux-docs/refs/heads/main/hibernation/kernel-6-11-workarounds/rfkill-suspender.sh -o rfkill-suspender.sh && clear && bash rfkill-suspender.sh

# This fixes NVME SSD "waking up" from standby in read-only mode.
grep -e "^GRUB_CMDLINE_LINUX_DEFAULT=\".*pcie_aspm=off" /etc/default/grub 1>/dev/null
if [[ $? -gt 0 ]]; then
  sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT="/GRUB_CMDLINE_LINUX_DEFAULT="pcie_aspm=off /g' /etc/default/grub
  grub-mkconfig -o /boot/grub/grub.cfg
fi

echo "Framework laptop customization complete. You should reboot now."
