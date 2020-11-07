#!/usr/bin/env bash

set -e

# keep track of the last executed command
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
# echo an error message before exiting
trap 'echo "\"${last_command}\" command filed with exit code $?."' EXIT

git config pull.rebase false

mkdir -p ~/.ssh
chmod 0700 ~/.ssh
[[ ! -f ~/.ssh/authorized_keys ]] && curl -L "https://github.com/rene-s.keys" --output ~/.ssh/authorized_keys
sed -i 's,^#PermitRootLogin .*,PermitRootLogin prohibit-password,g' /etc/makepkg.conf
systemctl restart sshd

echo "Schmidt DevOps \r (\l) -- setup on: $(date)" >/etc/issue

. ./01/002_packages.sh
. ./01/003_users.sh
. ./01/001_yay.sh
. ./01/004_system.sh
. ./01/005_locale.sh

echo "Done. "