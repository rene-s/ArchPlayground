#!/usr/bin/env bash

yay -Q seafile-client
RET=$?

if [[ $RET != "0" ]]; then
  answer=""
  question="Install Seafile client? (y/N)"
  ask "Install software" "Install software" "$question" "n" # because it takes some time to install it and we do not require it every time
  if [[ $answer == "y" ]]; then
    yay -S --noconfirm seafile-client
  fi
fi

clear
yay -Q seafile-client
RET=$?

mkdir -p ~/.config/autostart
if [[ $RET == "0" ]] && [[ ! -f ~/.config/autostart/seafile.desktop ]]; then
  cat <<EOF >~/.config/autostart/seafile.desktop
# \$Id: postinst.desktop 22 $
[Desktop Entry]
Name=Seafile
Comment=Seafile desktop sync client
TryExec=seafile-applet
Exec=seafile-applet
Icon=seafile
Type=Application
Categories=Network;FileTransfer;
EOF
fi
