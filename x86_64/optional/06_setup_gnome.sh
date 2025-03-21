#!/usr/bin/env bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DIR" || exit
. "${DIR}/../lib/sharedfuncs.sh"

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
pacman -Sy --noconfirm adw-gtk-theme \
                       vlc \
                       gimp \
                       gnome-control-center \
                       gnome-themes-extra \
                       gnome-shell-extensions \
                       gnome-disk-utility \
                       gnome-tweaks \
                       gnome-characters \
                       xorg-xrandr

# https://www.reddit.com/r/archlinux/comments/1aq97m8/gnomekeyring_14601_in_extratesting_disables/
# TODO: Prüfen, ob wirklich notwendig.
systemctl --user enable gcr-ssh-agent.socket
mkdir -p ~/.config/environment.d/
echo "SSH_AUTH_SOCK=\${XDG_RUNTIME_DIR}/gcr/ssh" > ~/.config/environment.d/ssh_auth_socket.conf
systemctl --user start gnome-keyring-daemon.service gnome-keyring-daemon.socket

# Make Firefox/Librewolf work better on Wayland
touch /etc/environment
if ! grep -qF "MOZ_ENABLE_WAYLAND=1" /etc/environment; then
  echo "MOZ_ENABLE_WAYLAND=1" >> /etc/environment
fi
