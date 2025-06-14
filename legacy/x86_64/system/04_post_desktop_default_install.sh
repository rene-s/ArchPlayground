#!/usr/bin/env bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DIR" || exit
. ../lib/sharedfuncs.sh

PRODUCT_NAME=$(cat /sys/devices/virtual/dmi/id/product_name)

bail_on_root

# first approach

# Make touch screen work for Thinkpad L390 model 20NRCTO1WW, see https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1849721
if [[ "${PRODUCT_NAME}" = "20NRCTO1WW" ]]; then
  echo "blacklist raydium_i2c_ts" | sudo tee /etc/modprobe.d/blacklist_raydium.conf
fi

yay -S --noconfirm \
  adobe-source-han-sans-otc-fonts \
  chrome-gnome-shell \
  cups \
  ttf-dejavu \
  dav1d \
  dconf-editor \
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
  gnome-shell-extensions \
  google-chrome \
  gotop-bin \
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
  lollypop \
  jdk8-openjdk \
  modemmanager \
  networkmanager \
  networkmanager-openvpn \
  networkmanager-wireguard \
  network-manager-applet \
  notepadqq \
  ntfs-3g \
  openvpn \
  pavucontrol \
  pipewire \
  seahorse \
  sane \
  splix \
  system-config-printer \
  terminator \
  tilix \
  vlc \
  xdg-desktop-portal \
  xorg-xbacklight \
  xorg-xrandr \
  wireguard-tools \
  wireless_tools \
  wpa_actiond \
  wpa_supplicant \
  xsel

# notes:
# xsel enables KeePass to write stuff to the clipboard
# Chrome: chrome://flags/#enable-webrtc-pipewire-capturer for desktop sharing
# splix is for Samsung printers

# P640RF=Tuxedo XC1406, 4180W15=Lenovo T420
if [ "$PRODUCT_NAME" == "P640RF" ] || [ "$PRODUCT_NAME" == "4180W15" ]; then
  yay -S --noconfirm \
    bbswitch-dkms \
    bumblebee \
    mesa-demos \
    primus \
    virtualgl

  sudo systemctl enable bumblebeed.service

  sudo usermod -a -G bumblebee re
  sudo usermod -a -G bumblebee st
fi

yay -R --noconfirm anjuta      # not required, gnome confuses opening links with opening anjuta sometimes
yay -R --noconfirm gnome-music # relies on tracker which in turn has issues with indexing music from symlinks, replaced with Lollypop
yay -R --noconfirm gnome-mahjongg # this is a place of work, no Mahjongg required

sudo systemctl enable gdm.service
sudo systemctl enable NetworkManager.service
sudo systemctl enable org.cups.cupsd.service

# Prepare for IntelliJ IDEA/PhpStorm; see https://confluence.jetbrains.com/display/IDEADEV/Inotify+Watches+Limit
echo "fs.inotify.max_user_watches = 524288" | sudo tee /etc/sysctl.d/inotify.conf

# Fix wrong permissions; fixes GDM sometimes not starting after installation
sudo chown -R gdm:gdm /var/lib/gdm/

# Set up bluetooth support
read -r -p "Set up bluetooth support? (y/N): " BLUETOOTH

if [[ $BLUETOOTH == "y" ]]; then
  yay -S bluez-firmware --noconfirm
  setup_bluetooth
fi

# Disable unsupported GNOME session types. @todo: idempotency
if [[ -f /usr/share/xsessions/gnome-classic.desktop ]]; then
  echo "Hidden=true" | sudo tee --append /usr/share/xsessions/gnome-classic.desktop
fi
if [[ -f /usr/share/xsessions/gnome-xorg.desktop ]]; then
  echo "Hidden=true" | sudo tee --append /usr/share/xsessions/gnome-xorg.desktop
fi

echo "Done."
echo "Reboot and login as user, then continue as shown in the README."
