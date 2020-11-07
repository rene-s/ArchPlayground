#!/usr/bin/env bash

mkdir -p ~/.ssh
chown 0700 ~/.ssh
curl -L "https://github.com/rene-s.keys" --output ~/.ssh/authorized_keys
sed -i 's,^#PermitRootLogin .*,PermitRootLogin prohibit-password,g' /etc/makepkg.conf
systemctl restart sshd

#sed -i 's,#MAKEFLAGS="-j2",MAKEFLAGS="-j$(nproc)",g' /etc/makepkg.conf