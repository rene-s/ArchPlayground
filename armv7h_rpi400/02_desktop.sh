#!/usr/bin/env bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DIR" || exit

https://github.com/Jack477/CommanderPi

yay -S \
  adobe-source-han-sans-otc-fonts \
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
  gnome-tweak-tool \
  gnome-user-share \
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
  tilix \
  vlc \
  xdg-desktop-portal \
  xorg-xbacklight \
  xorg-xrandr \
  wireguard-tools \
  wireless_tools \
  wpa_supplicant \
  xsel

yay -R anjuta         # not required, gnome confuses opening links with opening anjuta sometimes
yay -R gnome-music    # relies on tracker which in turn has issues with indexing music from symlinks, replaced with Lollypop
yay -R gnome-mahjongg # this is a place of work, no Mahjongg required

sudo systemctl enable gdm.service
sudo systemctl enable NetworkManager.service
sudo systemctl disable --now org.cups.cupsd.service

# Prepare for IntelliJ IDEA/PhpStorm; see https://confluence.jetbrains.com/display/IDEADEV/Inotify+Watches+Limit
echo "fs.inotify.max_user_watches = 64000" | sudo tee /etc/sysctl.d/inotify.conf

# Fix wrong permissions; fixes GDM sometimes not starting after installation
sudo chown -R gdm:gdm /var/lib/gdm/
yay -S bluez-firmware --noconfirm

sudo pacman -S bluez bluez-utils pulseaudio-bluetooth bluez-libs
sudo systemctl enable bluetooth.service

# In case of problems, list audio devices with ```pactl list cards | less``` and make sure a2dp sink is enabled.
# Select the "High Fidelity" profile using pavucontrol

# Fix: When using GDM, another instance of PulseAudio is started, which "captures" your bluetooth device
# connection. This can be prevented by masking the pulseaudio socket for the GDM user by doing the following:
sudo mkdir -p ~gdm/.config/systemd/user
sudo ln -s /dev/null ~gdm/.config/systemd/user/pulseaudio.socket

echo "Done."
echo "Reboot and login as user,"
echo "then continue with script 'x86_64/system/05_post_desktop_default_setup.sh' and"
