#!/usr/bin/env bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DIR" || exit
. "${DIR}/../../lib/sharedfuncs.sh"
bail_on_root

# Install other useful items
yay -Q oh-my-zsh-git || yay -S --noconfirm oh-my-zsh-git
yay -Q solaar || yay -S --noconfirm solaar
yay -Q flameshot || yay -S --noconfirm flameshot # also profits from AppIndicator support
yay -Q libfido2 || yay -S --noconfirm libfido2
yay -Q yubikey-manager || yay -S --noconfirm yubikey-manager
yay -Q yubikey-personalization || yay -S --noconfirm yubikey-personalization

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
