#!/usr/bin/env bash

echo "Note that the system does not run stable at the moment."
echo "There are frequent coredumps: libc.so.6 __clock_gettime64"
exit 1

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