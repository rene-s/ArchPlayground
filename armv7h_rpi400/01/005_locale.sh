#!/usr/bin/env bash

# Update timezone and system time
echo "Setting time and time zones..."
ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime
hwclock --systohc

# Setup locales and keymap
echo "Setup locales and keymap..."
echo "en_US.UTF-8 UTF-8" >/etc/locale.gen
echo "de_DE@euro ISO-8859-15" >>/etc/locale.gen
echo "de_DE.UTF-8 UTF-8" >>/etc/locale.gen

echo "LANG=de_DE.UTF-8" >/etc/locale.conf
echo "KEYMAP=de-latin1" >/etc/vconsole.conf

locale-gen