#!/usr/bin/env bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DIR" || exit
. ../lib/sharedfuncs.sh

bail_on_root

if [[ $DESKTOP_SESSION != "gnome" ]]; then
  print_danger "GNOME should be running at this point. It does not, which indicates a previous error."
  exit 1
fi

mkdir -p ~/Bilder

# Set X11 keymap
localectl --no-convert set-x11-keymap de pc105 nodeadkeys
gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'de')]"

# Set wallpaper
SCREENS=("1024x768" "1280x1024" "1440x900" "1440x1050" "1600x939" "1600x1024" "1920x1080" "1600x1200" "1920x1200" "2560x1440" "3200x1800" "2560x2048" "1366x768" "4080x768")
URL="https://raw.githubusercontent.com/Schmidt-DevOps/Schmidt-DevOps-Static-Assets/master/img/wallpaper/"

WALLPAPER_DIR="/home/${USER}/Bilder/SDO-Wallpaper"
mkdir -p "$WALLPAPER_DIR"

for screen in "${SCREENS[@]}"; do
  curl -sL "${URL}${screen}_debian-greyish-wallpaper-widescreen.png" --output "${WALLPAPER_DIR}/debian-greyish-wallpaper-widescreen_${screen}.png"
done

DETECTED_SCREEN=$(DISPLAY=:0 xrandr | grep -F '*' | cut -d' ' -f4)
SEEK_WALLPAPER="${WALLPAPER_DIR}/debian-greyish-wallpaper-widescreen_${DETECTED_SCREEN}.png"

if [[ -f $SEEK_WALLPAPER ]]; then
  WALLPAPER=$SEEK_WALLPAPER
else
  WALLPAPER="${WALLPAPER_DIR}/debian-greyish-wallpaper-widescreen_${SCREENS[0]}.png"
fi

# https://wiki.archlinux.org/index.php/GNOME
gsettings set org.gnome.desktop.background picture-uri "file://$WALLPAPER"
gsettings set org.gnome.desktop.screensaver picture-uri "file://$WALLPAPER"
gsettings set org.gnome.desktop.interface clock-show-date true
gsettings set org.gnome.desktop.interface clock-show-weekday true
gsettings set org.gnome.desktop.calendar show-weekdate true
gsettings set org.gnome.desktop.interface enable-hot-corners false
gsettings set org.gnome.desktop.wm.preferences button-layout ":minimize,maximize,close"

# Set screensaver photo
sudo mkdir -p /usr/local/share/pixmaps/wallpaper
sudo cp "$WALLPAPER" /usr/local/share/pixmaps/wallpaper/.sdo_wallpaper.png

GSCHEMA="/usr/share/glib-2.0/schemas/org.gnome.desktop.screensaver.gschema.override"

echo "[org.gnome.desktop.screensaver]" | sudo tee $GSCHEMA
echo "picture-uri=\"/usr/local/share/pixmaps/wallpaper/.sdo_wallpaper.png\"" | sudo tee --append $GSCHEMA
sudo glib-compile-schemas /usr/share/glib-2.0/schemas/

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

# Configure git
read -r -p "Enter your email address: " email
read -r -p "Enter your name: " nameofuser

git config --global user.email "${email}"
git config --global user.name "${nameofuser}"

# Misc stuff
sudo chfn -f "${nameofuser}" "$USER"                        # Set name of user
xdg-mime default org.gnome.Nautilus.desktop inode/directory # see https://wiki.archlinux.de/title/GNOME

# Install AUR packages
yay -Q seafile-client
RET=$?

if [[ $RET != "0" ]]; then
  answer=""
  question="Install Seafile client? (y/N)"
  ask "Install software" "Install software" "$question" "n"
  if [[ $answer == "y" ]]; then # ask because it takes some time to install it and we do not require it every time
    yay -Q seafile-client || yay -S --noconfirm seafile-client
  fi
fi

# Install and enable AppIndicator support
yay -Q gnome-shell-extension-appindicator-git
RET=$?

if [[ $RET != "0" ]]; then
  yay -S --noconfirm gnome-shell-extension-appindicator-git # activate: tweaks > extensions > Kstatusnotifieritem
  gsettings set org.gnome.shell enabled-extensions "['appindicatorsupport@rgcjonas.gmail.com','window-list@gnome-shell-extensions.gcampax.github.com']"
fi

# Install other useful items
yay -Q micro-bin || yay -S --noconfirm micro-bin
yay -Q oh-my-zsh-git || yay -S --noconfirm oh-my-zsh-git
yay -Q solaar || yay -S --noconfirm solaar
yay -Q flameshot || yay -S --noconfirm flameshot # also profits from AppIndicator support

# Remove redundant packages
yay -Q vi 2>/dev/null && yay -R --noconfirm vi
yay -Q vim 2>/dev/null && yay -R --noconfirm vim

echo "Done. You may want to set up default keybindings with 'sh /usr/local/share/tmp/ArchPlayground/user/setup_custom_keybindings.sh'"
