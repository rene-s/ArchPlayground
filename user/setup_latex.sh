#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";cd $DIR
. ../lib/sharedfuncs.sh

bail_on_root
bail_on_missing_yay

sudo pacman -S texlive-most kile
yay -S koma-script