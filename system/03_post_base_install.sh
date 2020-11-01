#!/usr/bin/env bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DIR" || exit
. ../lib/sharedfuncs.sh

bail_on_root

sudo systemctl enable --now fstrim.timer
sudo systemctl enable --now systemd-timesyncd.service
sudo systemctl enable --now acpid

sudo systemctl start dhcpcd.service
echo "Waiting for the network connection..."
sleep 10

TMP_DIR=$(mktemp -d)
pacman -Q --noconfirm yay 2>/dev/null
RET=$?

if [ $RET != "0" ]; then
  echo "Installing yay..."
  cd "$TMP_DIR" || exit
  git clone https://aur.archlinux.org/yay.git
  cd yay || exit
  makepkg -si --noconfirm
fi

cd || exit
rm -rf "$TMP_DIR"

# use all possible cores for subsequent package builds
# shellcheck disable=SC2016
sed -i 's,#MAKEFLAGS="-j2",MAKEFLAGS="-j$(nproc)",g' /etc/makepkg.conf

# don't compress the packages built here
sed -i "s,PKGEXT='.pkg.tar.zst',PKGEXT='.pkg.tar',g" /etc/makepkg.conf

# ease pam_faillock a bit because it drives me crazy with my wonky keyboard
if [[ -f /etc/security/faillock.conf ]]; then
  sed -i 's,# *deny *= *3,deny = 6,g' /etc/security/faillock.conf
  sed -i 's,# *unlock_time *= *600,unlock_time = 60,g' /etc/security/faillock.conf
fi

echo "Done."
echo "Exit the shell session, log in as user and continue with 'sh /usr/local/share/tmp/ArchPlayground/system/04_post_desktop_default_install.sh'."

# @todo: $ sudo nano /etc/NetworkManager/NetworkManager.conf
#.
#.
#[ifupdown]
#managed=true
# Hilft dem NM, VPN-Verbindungen aufzubauen

# yay -S wireguard-lts networkmanager-wireguard-git

# @todo: Add systemd timers: https://unix.stackexchange.com/a/590001
