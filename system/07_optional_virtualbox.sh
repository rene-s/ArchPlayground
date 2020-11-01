#!/usr/bin/env bash

# This script sets up a system as VirtualBox host or VirtualBox guest

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DIR" || exit
. ../lib/sharedfuncs.sh

bail_on_root

yay -Q virtualbox-guest-dkms 2>/dev/null || yay -S --noconfirm virtualbox-guest-dkms

# Setup environment
VM=$(dmidecode -s system-product-name)
if [[ $VM == "VirtualBox" ]]; then
  yay -Q virtualbox-guest-utils 2>/dev/null || yay -S --noconfirm virtualbox-guest-utils
  yay -Q xf86-video-vmware 2>/dev/null || yay -S --noconfirm xf86-video-vmware
  sudo systemctl enable vboxservice.service
  sudo systemctl start vboxservice.service
else
  yay -Q virtualbox 2>/dev/null || yay -S --noconfirm virtualbox

  sudo vboxreload

  sudo usermod -aG vboxsf re
  sudo usermod -aG vboxsf st

  sudo usermod -aG vboxusers re
  sudo usermod -aG vboxusers st
fi

echo "Done."
