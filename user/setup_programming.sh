#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";cd $DIR
. ../lib/sharedfuncs.sh

bail_on_root
bail_on_missing_yaourt

pacman -S --noconfirm \
intellij-idea-community-edition \
php \
composer \
xdebug

yaourt -S phpstorm

wget https://phar.phpunit.de/phpunit.phar -O /tmp/phpunit.phar
sudo mv /tmp/phpunit.phar /usr/bin/phpunit
sudo chmod +x /usr/bin/phpunit