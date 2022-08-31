#!/usr/bin/env bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DIR" || exit
. "${DIR}/../../lib/sharedfuncs.sh"
bail_on_root

sudo mkdir -p /var/lib/AccountsService/users
sudo mkdir -p /usr/local/share/pixmaps/faces

# Set avatar
AVATAR="${USER}"
SVG_FILE="/home/${USER}/Bilder/.${AVATAR}.svg"
PNG_FILE="/usr/local/share/pixmaps/faces/${AVATAR}.png"
USER_FILE="/var/lib/AccountsService/users/${AVATAR}"

curl -L "https://raw.githubusercontent.com/Schmidt-DevOps/Schmidt-DevOps-Static-Assets/master/img/avatar/${AVATAR}.svg" --output "${SVG_FILE}"

if [[ -f "${SVG_FILE}" ]] && [[ -d /home/${USER}/Bilder/ ]]; then
  cd /home/${USER}/Bilder/ || exit
  convert ".${AVATAR}.svg" ".${AVATAR}.png"

  # Scale avatar to 96px width, then crop 96x96px with 5px offset from the top. Save to non-home dir because GDM does not seem to like those.
  sudo convert ".${AVATAR}.png" -resize 96x -crop 96x96+0+5 "${PNG_FILE}"

  echo "[User]" | sudo tee "${USER_FILE}"
  echo "Language=de_DE.UTF-8" | sudo tee --append "${USER_FILE}"
  echo "XSession=" | sudo tee --append "${USER_FILE}"
  echo "Icon=${PNG_FILE}" | sudo tee --append "${USER_FILE}"
  echo "SystemAccount=false" | sudo tee --append "${USER_FILE}"
fi