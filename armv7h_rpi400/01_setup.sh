#!/usr/bin/env bash

git config pull.rebase false

mkdir -p ~/.ssh
chmod 0700 ~/.ssh
[[ ! -f ~/.ssh/authorized_keys ]] && curl -L "https://github.com/rene-s.keys" --output ~/.ssh/authorized_keys
sed -i 's,^#PermitRootLogin prohibit-password,PermitRootLogin prohibit-password,g' /etc/makepkg.conf
systemctl restart sshd

./01/002_packages.sh
./01/003_users.sh
./01/001_yay.sh
./01/004_system.sh
./01/005_locale.sh

read -r -p "Host name: " HOSTNAME # have the interaction aggregated
hostnamectl set-hostname ${HOSTNAME}

cp ./config.txt /boot/
echo "Done. "