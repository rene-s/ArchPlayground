#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";cd $DIR
. ../lib/sharedfuncs.sh

bail_on_root

pacman -Q yaourt 2>/dev/null

if [ $? != "0" ]; then
	echo "Installing yaourt..."
	wget https://aur.archlinux.org/cgit/aur.git/snapshot/package-query.tar.gz -O - | tar xz -C /tmp
	wget https://aur.archlinux.org/cgit/aur.git/snapshot/yaourt.tar.gz -O - | tar xz -C /tmp/

	cd /tmp/package-query;makepkg -si
	cd /tmp/yaourt;makepkg -si
fi

TMP_DIR=`mktemp -d`
pacman -Q cower 2>/dev/null

if [ $? != "0" ]; then
    cd $TMP_DIR
	echo "Installing cower..."
	sudo pacman -S expac yajl --noconfirm
	gpg --recv-keys --keyserver hkp://pgp.mit.edu 1EB2638FF56C0C53
	curl -o PKGBUILD https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=cower
	makepkg -i PKGBUILD --noconfirm
fi

pacman -Q pacaur 2>/dev/null

if [ $? != "0" ]; then
    cd $TMP_DIR
	echo "Installing pacaur..."
	curl -o PKGBUILD https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=pacaur
	makepkg -i PKGBUILD --noconfirm
fi

cd
rm -rf $TMP_DIR
echo "Done."