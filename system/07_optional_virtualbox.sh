#!/usr/bin/env bash

# This script sets up a system as VirtualBox host or VirtualBox guest

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";cd $DIR
. ../lib/sharedfuncs.sh

bail_on_user

# Setup environment
VM=`dmidecode -s system-product-name`
if [[ $VM == "VirtualBox" ]]; then
    yay -Q virtualbox-guest-dkms 2>/dev/null || pacman -S --noconfirm virtualbox-guest-dkms
else
    yay -S --noconfirm virtualbox
fi

echo "Done."