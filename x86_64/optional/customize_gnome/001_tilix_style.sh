#!/usr/bin/env bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DIR" || exit
. ../lib/sharedfuncs.sh
bail_on_root

pacman -Q tilix 2>/dev/null || sudo pacman -Sy --noconfirm tilix

# Style Tilix
profile_id=$(gsettings get com.gexperts.Tilix.ProfilesList default | tr -d "'")
gsettings set com.gexperts.Tilix.Profile:/com/gexperts/Tilix/profiles/"${profile_id}"/ background-transparency-percent 8
gsettings set com.gexperts.Tilix.Profile:/com/gexperts/Tilix/profiles/"${profile_id}"/ background-color '#272822'
gsettings set com.gexperts.Tilix.Profile:/com/gexperts/Tilix/profiles/"${profile_id}"/ badge-color '#ffffff'
gsettings set com.gexperts.Tilix.Profile:/com/gexperts/Tilix/profiles/"${profile_id}"/ badge-position 'southeast'
gsettings set com.gexperts.Tilix.Profile:/com/gexperts/Tilix/profiles/"${profile_id}"/ palette "['#272822', '#F92672', '#A6E22E', '#F4BF75', '#66D9EF', '#AE81FF', '#A1EFE4', '#F8F8F2', '#75715E', '#F92672', '#A6E22E', '#F4BF75', '#66D9EF', '#AE81FF', '#A1EFE4', '#F9F8F5']"
gsettings set com.gexperts.Tilix.Profile:/com/gexperts/Tilix/profiles/"${profile_id}"/ badge-text '${columns}x${rows}'
gsettings set com.gexperts.Tilix.Settings theme-variant 'dark'
gsettings set com.gexperts.Tilix.Profile:/com/gexperts/Tilix/profiles/"${profile_id}"/ badge-font 'Sans Italic 6'