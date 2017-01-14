#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";cd $DIR
. ../lib/sharedfuncs.sh

bail_on_root
bail_on_missing_yaourt

pacman -S --noconfirm \
intellij-idea-community-edition

yaourt -S phpstorm