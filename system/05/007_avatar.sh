#!/usr/bin/env bash

if [[ -z $USER ]]; then
  USER=$(whoami)
fi

# Set avatar
AVATAR="${USER}"
curl -L "https://raw.githubusercontent.com/Schmidt-DevOps/Schmidt-DevOps-Static-Assets/master/img/avatar/${AVATAR}.svg" --output "/home/${USER}/Bilder/.${AVATAR}.svg"

sudo mkdir -p /var/lib/AccountsService/users
sudo mkdir -p /usr/local/share/pixmaps/faces

cd ~/Bilder/ || exit
convert ".${USER}.svg" ".${USER}.png"

# Scale avatar to 96px width, then crop 96x96px with 5px offset from the top. Save to non-home dir because GDM does not seem to like those.
sudo convert ".${USER}.png" -resize 96x -crop 96x96+0+5 "/usr/local/share/pixmaps/faces/${USER}.png"

USER_FILE=/var/lib/AccountsService/users/${USER}

echo "[User]" | sudo tee "$USER_FILE"
echo "Language=de_DE.UTF-8" | sudo tee --append "$USER_FILE"
echo "XSession=" | sudo tee --append "$USER_FILE"
echo "Icon=/usr/local/share/pixmaps/faces/${USER}.png" | sudo tee --append "$USER_FILE"
echo "SystemAccount=false" | sudo tee --append "$USER_FILE"
