#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";cd $DIR
. ../lib/sharedfuncs.sh

bail_on_root
bail_on_missing_yay

yay -S --noconfirm \
intellij-idea-ultimate-edition \
php \
composer \
xdebug

wget https://phar.phpunit.de/phpunit.phar -O /tmp/phpunit.phar
sudo mv /tmp/phpunit.phar /usr/bin/phpunit
sudo chmod +x /usr/bin/phpunit

if [ -f /etc/php/conf.d/xdebug.ini ]; then
    sudo sed -i -- "s/^;zend_extension=xdebug.so/zend_extension=xdebug.so/g" /etc/php/conf.d/xdebug.ini
fi
