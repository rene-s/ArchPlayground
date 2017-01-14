#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cd $DIR

. ../lib/sharedfuncs.sh

if [ "${USER}" == "root" ]; then
    print_danger "This script is supposed to be run as user, not as root."
    exit 1
fi

bail_on_missing_yaourt

sudo pacman -S texlive-most kile
yaourt -S koma-script