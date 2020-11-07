#!/usr/bin/env bash

git config pull.rebase false

mkdir -p ~/.ssh
chown 0700 ~/.ssh
[[ ! -f ~/.ssh/authorized_keys ]] && curl -L "https://github.com/rene-s.keys" --output ~/.ssh/authorized_keys
sed -i 's,^#PermitRootLogin .*,PermitRootLogin prohibit-password,g' /etc/makepkg.conf
systemctl restart sshd

#sed -i 's,#MAKEFLAGS="-j2",MAKEFLAGS="-j$(nproc)",g' /etc/makepkg.conf