#!/usr/bin/env bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DIR" || exit
. "${DIR}/../../lib/sharedfuncs.sh"
bail_on_root

# Install other useful items
yay_inst_pkg oh-my-zsh-git
yay_inst_pkg solaar
yay_inst_pkg flameshot
yay_inst_pkg libfido2
yay_inst_pkg yubikey-manager
yay_inst_pkg yubikey-personalization
yay_inst_pkg bluez
yay_inst_pkg bluez-util
yay_inst_pkg librewolf-bin
yay_inst_pkg keepassxc
yay_inst_pkg bluez-util

sudo systemctl enable --now bluetooth.service
yay -S --noconfirm ttf-roboto noto-fonts noto-fonts-cjk adobe-source-han-sans-cn-fonts adobe-source-han-serif-cn-fonts ttf-dejavu

mkdir -p ~/.config/autostart
if [[ ! -f ~/.config/autostart/org.flameshot.Flameshot.desktop ]]; then
  cat <<EOF >~/.config/autostart/org.flameshot.Flameshot.desktop
# \$Id: postinst.desktop 22 $
[Desktop Entry]
Name=Flameshot
GenericName=Screenshot tool
Comment=Powerful yet simple to use screenshot software.
Comment[de]=Schlichte, leistungsstarke Screenshot-Software
Keywords=flameshot;screenshot;capture;shutter;
Keywords[de]=flameshot;screenshot;Bildschirmfoto;Aufnahme;
Exec=flameshot
Icon=org.flameshot.Flameshot
Terminal=false
Type=Application
Categories=Graphics;
StartupNotify=false
Actions=Configure;Capture;Launcher;
X-DBUS-StartupType=Unique
X-DBUS-ServiceName=org.flameshot.Flameshot
X-KDE-DBUS-Restricted-Interfaces=org_kde_kwin_effect-screenshot

[Desktop Action Configure]
Name=Configure
Name[de]=Einstellungen
Exec=flameshot config

[Desktop Action Capture]
Name=Take screenshot
Name[de]=Bildschirmfoto aufnehmen
Exec=flameshot gui --delay 500

[Desktop Action Launcher]
Name=Open launcher
Name[de]=Starter öffnen
Exec=flameshot launcher

EOF
fi
