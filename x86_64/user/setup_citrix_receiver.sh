#!/usr/bin/env bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DIR" || exit
. ../lib/sharedfuncs.sh

bail_on_root

# https://wiki.archlinux.org/index.php/Citrix

yay -S icaclient chromium
