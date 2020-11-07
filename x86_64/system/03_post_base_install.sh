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
sudo sed -i 's,#MAKEFLAGS="-j2",MAKEFLAGS="-j$(nproc)",g' /etc/makepkg.conf

# don't compress the packages built here
sudo sed -i "s,PKGEXT='.pkg.tar.zst',PKGEXT='.pkg.tar',g" /etc/makepkg.conf

# ease pam_faillock a bit because it drives me crazy with my wonky keyboard
if [[ -f /etc/security/faillock.conf ]]; then
  sudo sed -i 's,# *deny *= *3,deny = 6,g' /etc/security/faillock.conf
  sudo sed -i 's,# *unlock_time *= *600,unlock_time = 60,g' /etc/security/faillock.conf
fi

# @todo Make more elegant
for playground_user in 're' 'st'; do
  sudo mkdir "/home/${playground_user}/.ssh"
  sudo touch "/home/${playground_user}/.ssh/authorized_keys"
  sudo curl -L "https://github.com/rene-s.keys" --output "/home/${playground_user}/.ssh/rene-s.keys"
  sudo curl -L "https://github.com/steffi-s.keys" --output "/home/${playground_user}/.ssh/steffi-s.keys"
  sudo bash -c "cat \"/home/${playground_user}/.ssh/rene-s.keys\" \"/home/${playground_user}/.ssh/steffi-s.keys\" >>\"/home/${playground_user}/.ssh/authorized_keys\""
  sudo chown -R "${playground_user}:users" "/home/${playground_user}/.ssh"
  sudo chmod 0700 "/home/${playground_user}/.ssh"
  sudo chmod 0644 "/home/${playground_user}/.ssh/*keys"
done

echo "Done."
echo "Continue with 'sh /usr/local/share/tmp/ArchPlayground/system/04_post_desktop_default_install.sh'."

# @todo: $ sudo nano /etc/NetworkManager/NetworkManager.conf
#.
#.
#[ifupdown]
#managed=true
# Hilft dem NM, VPN-Verbindungen aufzubauen

# yay -S wireguard-lts networkmanager-wireguard-git

# @todo: Add systemd timers: https://unix.stackexchange.com/a/590001
