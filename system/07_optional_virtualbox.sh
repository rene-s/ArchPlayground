#!/usr/bin/env bash

# This script sets up a system as VirtualBox host or VirtualBox guest

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";cd $DIR
. ../lib/sharedfuncs.sh

bail_on_user

yay -Q virtualbox-guest-dkms 2>/dev/null || yay -S --noconfirm virtualbox-guest-dkms

# Setup environment
VM=`dmidecode -s system-product-name`
if [[ $VM == "VirtualBox" ]]; then
    yay -Q virtualbox-guest-utils 2>/dev/null || yay -S --noconfirm virtualbox-guest-utils
    yay -Q xf86-video-vmware 2>/dev/null || yay -S --noconfirm xf86-video-vmware
    systemctl enable vboxservice.service
    systemctl start vboxservice.service
else
    yay -Q virtualbox 2>/dev/null || yay -S --noconfirm virtualbox

    vboxreload

    usermod -aG vboxsf re
    usermod -aG vboxsf st
fi

echo "Done."