#!/usr/bin/env bash

#set -e

URL_ZSHRC="https://raw.githubusercontent.com/Schmidt-DevOps/Schmidt-DevOps-Static-Assets/master/cfg/_zshrc"
curl -L "$URL_ZSHRC" --output "/tmp/.zshrc"
echo 'export PATH=$PATH:/opt/vc/bin' >> "/tmp/.zshrc"

for playground_user in 'root' 're' 'st'; do
  if [[ "$playground_user" == "root" ]]; then
    cp /tmp/.zshrc /root/.zshrc
    chown "$playground_user:$playground_user" "/$playground_user/.zshrc"
  else
    id ${playground_user}
    RET=$?

    if [[ $RET != "0" ]]; then
      useradd -m -g users -G wheel ${playground_user}
      echo "Enter password for user ${playground_user}:"
      passwd "${playground_user}"
    fi

    cp /tmp/.zshrc "/home/$playground_user/.zshrc"
    chown $playground_user:users "/home/$playground_user/.zshrc"
    usermod -aG network "$playground_user"
    usermod -aG wheel "$playground_user"
  fi
  chsh -s /usr/bin/zsh "$playground_user"
done

if [[ -f /etc/sudoers ]]; then
  sed -i "s,# %wheel ALL=(ALL) ALL,%wheel ALL=(ALL) ALL,g" /etc/sudoers
fi
