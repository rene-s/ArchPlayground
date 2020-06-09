#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";cd $DIR
. ../lib/sharedfuncs.sh

PRODUCT_NAME=`cat /sys/devices/virtual/dmi/id/product_name`

bail_on_user

# first approach

yay -S --noconfirm \
adobe-source-han-sans-otc-fonts \
cups \
ttf-dejavu \
dav1d \
dialog \
eog \
exfat-utils \
firefox \
gdm \
gimp \
gnome \
gnome-extra \
gnome-tweak-tool \
gnome-user-share \
gst-libav \
gst-plugins-ugly \
gtk3-print-backends \
imagemagick \
iw \
noto-fonts-emoji \
libreoffice-still \
libmicrodns \
libu2f-host \
linux-headers \
jdk8-openjdk \
modemmanager \
networkmanager \
networkmanager-openvpn \
network-manager-applet \
ntfs-3g \
openvpn \
pavucontrol \
pipewire \
qt4 \
rhythmbox \
seahorse \
sane \
splix \
system-config-printer \
tilix \
vlc \
xdg-desktop-portal \
xorg-xbacklight \
xorg-xrandr \
wireless_tools \
wpa_actiond \
wpa_supplicant \
gotop-bin \
jedit \
xsel

# notes:
# xsel enables KeePass to write stuff to the clipboard
# Chrome: chrome://flags/#enable-webrtc-pipewire-capturer for desktop sharing
# splix is for Samsung printers

# P640RF=Tuxedo XC1406, 4180W15=Lenovo T420
if [ $PRODUCT_NAME == "P640RF" ] || [ $PRODUCT_NAME == "4180W15" ]; then
    yay -S --noconfirm \
        bbswitch-dkms \
        bumblebee \
        mesa-demos \
        primus \
        virtualgl

    systemctl enable bumblebeed.service

    sudo usermod -a -G bumblebee re
    sudo usermod -a -G bumblebee st
fi

yay -R --noconfirm anjuta # not required, gnome confuses opening links with opening anjuta sometimes
yay -R --noconfirm gnome-music # relies on tracker which in turn has issues with indexing music from symlinks, replaced with good ol' RhythmBox

systemctl enable gdm.service
systemctl enable NetworkManager.service
systemctl enable org.cups.cupsd.service

# Prepare for IntelliJ IDEA/PhpStorm; see https://confluence.jetbrains.com/display/IDEADEV/Inotify+Watches+Limit
echo "fs.inotify.max_user_watches = 524288" > /etc/sysctl.d/inotify.conf

# Fix wrong permissions; fixes GDM sometimes not starting after installation
chown -R gdm:gdm /var/lib/gdm/

# Set up bluetooth support
read -p "Set up bluetooth support? (y/N): " BLUETOOTH

if [[ $BLUETOOTH == "y" ]]
then
    yay -S bluez-firmware --noconfirm
    setup_bluetooth
fi

# Disable unsupported GNOME session types. @todo: idempotency
if [[ -f /usr/share/xsessions/gnome-classic.desktop ]]; then
    echo "Hidden=true" >> /usr/share/xsessions/gnome-classic.desktop
fi
if [[ -f /usr/share/xsessions/gnome-xorg.desktop ]] ; then
    echo "Hidden=true" >> /usr/share/xsessions/gnome-xorg.desktop
fi

# Test placing a desktop file for easy access
cat << EOF > /usr/share/applications/postinst.desktop
# \$Id: postinst.desktop 22 $
[Desktop Entry]
Name=PostInst
GenericName=PostInst
Comment=PostInst
Exec=bash /usr/local/share/tmp/ArchPlayground/system/05_post_desktop_default_setup.sh
Terminal=true
Type=Application
Icon=utilities-terminal
Categories=GNOME;GTK;Utility;%
EOF

echo "Done."
echo "Reboot and login as user, then continue with /usr/local/share/tmp/ArchPlayground/system/05_post_desktop_default_setup.sh"


#QT_SCALE_FACTOR=1
#
#QT_QPA_PLATFORM=wayland
#
#QT_WAYLAND_DISABLE_WINDOWDECORATION=1
#
#XDG_SESSION_TYPE=wayland
#
#MOZ_ENABLE_WAYLAND=1
#
#GDK_BACKEND=wayland