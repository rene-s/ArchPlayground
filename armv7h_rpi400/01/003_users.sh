#!/usr/bin/env bash

URL_ZSHRC="https://raw.githubusercontent.com/Schmidt-DevOps/Schmidt-DevOps-Static-Assets/master/cfg/_zshrc"

for playground_user in 'root' 're' 'st'; do
  if [ "$playground_user" == "root" ]; then
    curl -L $URL_ZSHRC --output /mnt/root/.zshrc
    chown "$playground_user:$playground_user" "/$playground_user/.zshrc"
  else
    echo "Enter password for user ${playground_user}:"
    passwd "${playground_user}"

    curl -L $URL_ZSHRC --output "/mnt/home/$playground_user/.zshrc"
    chown $playground_user:users /home/$playground_user/.zshrc
    usermod -aG network $playground_user
    usermod -aG wheel $playground_user
  fi
  chsh -s /usr/bin/zsh $playground_user
endfor

[[ -f /mnt/etc/sudoers ]] && sed -i "s,#%wheel ALL=\(ALL\) ALL,%wheel ALL=(ALL) ALL,g" /mnt/etc/sudoers
