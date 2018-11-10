#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";cd $DIR
. ../lib/sharedfuncs.sh

bail_on_root

TMP_DIR=`mktemp -d`
pacman -Q yay 2>/dev/null

if [ $? != "0" ]; then
	echo "Installing yay..."
	cd $TMP_DIR
	git clone https://aur.archlinux.org/yay.git
    cd yay;makepkg -si
fi

cd
rm -rf $TMP_DIR
echo "Done."