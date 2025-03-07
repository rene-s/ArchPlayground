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

systemctl disable --now tlp 
pacman -R tlp
pacman -S power-profiles-daemon
systemctl enable --now power-profiles-daemon

curl -s https://raw.githubusercontent.com/FrameworkComputer/linux-docs/refs/heads/main/hibernation/kernel-6-11-workarounds/rfkill-suspender.sh -o rfkill-suspender.sh && clear && bash rfkill-suspender.sh

