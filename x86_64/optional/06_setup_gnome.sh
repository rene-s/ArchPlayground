#!/usr/bin/env bash

# This script sets up a user account. Sets up zsh as default shell.

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DIR" || exit
. ../lib/sharedfuncs.sh

bail_on_user
#
#function install_gnome() {
#  pacman -Sy --noconfirm gdm gnome
#  return $?
#}
#
#install_gnome
#RET=$?
#
#if [[ "${RET}" != "0" ]]; then
#  # So many dependencies! Maybe installation failed due to outdated/missing keys? Refresh & retry.
#  pacman-key --refresh # execute on demand only b/c it's rather slow.
#  install_gnome
#  RET=$?
#  if [[ "${RET}" != "0" ]]; then
#    echo "Welp, something is broken here."
#    exit 1
#  fi
#fi
#
##   networkmanager-wireguard-git
##   wireguard-lts
#
#chown -R gdm:gdm /var/lib/gdm/
#
# Install the rest
pacman -Sy --noconfirm vlc \
                       gimp \
                       notepadqq \
                       gnome-shell-extensions \
                       xorg-xrandr
#
#systemctl enable gdm.service
#
# Make Firefox/Librewolf work better on Wayland
touch /etc/environment
if ! grep -qF "MOZ_ENABLE_WAYLAND=1" /etc/environment; then
  echo "MOZ_ENABLE_WAYLAND=1" >> /etc/environment
fi

#echo "Reboot or run 'systemctl start gdm' and log in as user."
