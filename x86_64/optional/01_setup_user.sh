#!/usr/bin/env bash

# This script sets up a user account. Sets up zsh as default shell.

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DIR" || exit
. "${DIR}/../lib/sharedfuncs.sh"
bail_on_user

function usage {
  echo "$0 <username>"
  exit 0
}

pacman -Q zsh 2>/dev/null || pacman -Sy --noconfirm zsh
pacman -Q wl-clipboard 2>/dev/null || pacman -Sy --noconfirm wl-clipboard

USERNAME="$1"

if [[ "${USERNAME}" == "" ]]; then
  usage
fi

URL_ZSHRC="https://raw.githubusercontent.com/Schmidt-DevOps/Schmidt-DevOps-Static-Assets/master/cfg/_zshrc"
curl -L "$URL_ZSHRC" --output "/tmp/.zshrc"

# shellcheck disable=SC2016 # single quotes are deliberate as var expansion is undesired here.
echo 'export PATH=$PATH:/opt/vc/bin' >> "/tmp/.zshrc"

id "${USERNAME}"
RET=$?

if [[ $RET != "0" ]]; then
  useradd -m -g users "${USERNAME}"
  echo "Enter password for user ${USERNAME}:"
  passwd "${USERNAME}"
fi

cp /tmp/.zshrc "/home/${USERNAME}/.zshrc"
chown "${USERNAME}":users "/home/${USERNAME}/.zshrc"

usermod -aG network "${USERNAME}"
usermod -aG users "${USERNAME}"

answer=""
question="Add user to group 'wheel' for super user access? (y/N)"
title="Grant root for user"
ask "$title" "$title" "$question" "n" # because it takes some time to install it and we do not require it every time
if [[ $answer == "y" ]] || [[ $answer == "Y" ]]; then
  usermod -aG wheel "${USERNAME}"
fi

chsh -s /usr/bin/zsh "${USERNAME}"

if [[ -f /etc/sudoers ]]; then
  echo "%wheel ALL=(ALL:ALL) ALL" > /etc/sudoers.d/10_wheel
  echo "Make sure to reboot after running this script."
fi

answer=""
question="Enter github.com username or skip with 'n'/enter"
title="Import SSH pub keys?"
ask "$title" "$title" "$question" "n" # because it takes some time to install it and we do not require it every time

# TODO yeah maybe account for possible failure here...
if [[ $answer != "n" ]] && [[ $answer != "" ]] && [[ $answer != "y" ]]; then
  sudo mkdir "/home/${USERNAME}/.ssh"
  sudo touch "/home/${USERNAME}/.ssh/authorized_keys"
  sudo curl -L "https://github.com/$answer.keys" --output "/home/${USERNAME}/.ssh/$answer.keys"
  sudo bash -c "cat \"/home/${USERNAME}/.ssh/$answer.keys\" \"/home/${USERNAME}/.ssh/$answer.keys\" >>\"/home/${USERNAME}/.ssh/authorized_keys\""
  sudo chown -R "${USERNAME}:users" "/home/${USERNAME}/.ssh"
  sudo chmod 0700 /home/"${USERNAME}"/.ssh
  sudo chmod 0644 /home/"${USERNAME}"/.ssh/*keys
fi
