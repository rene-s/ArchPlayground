#!/usr/bin/env bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DIR" || exit
. ../lib/sharedfuncs.sh

bail_on_user

# first minimalistic approach

yay -S --noconfirm \
  connman \
  lxappearance \
  lxqt \
  oxygen-icons \
  sddm \
  wpa_supplicant

echo "Done."
echo "Reboot and login as user, then continue with /usr/local/share/tmp/ArchPlayground/system/05_post_desktop_default_setup.sh"
