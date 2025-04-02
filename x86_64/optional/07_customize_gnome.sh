# This script customizes GNOME

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DIR" || exit
. "${DIR}/../lib/sharedfuncs.sh"
bail_on_root

if [[ $DESKTOP_SESSION != "gnome" ]] && [[ $DESKTOP_SESSION != "gnome-xorg" ]]; then
  echo "This script needs to be run in a GNOME session. Log into GNOME and retry."
  exit 1
fi

mkdir -p ~/Bilder

"${DIR}/customize_gnome/009_keymap.sh"
"${DIR}/customize_gnome/005_wallpaper.sh"
"${DIR}/customize_gnome/006_gnome_settings.sh"
"${DIR}/customize_gnome/008_git.sh"

# Misc stuff
xdg-mime default org.gnome.Nautilus.desktop inode/directory # see https://wiki.archlinux.de/title/GNOME

"${DIR}/customize_gnome/002_appindicator.sh"
"${DIR}/customize_gnome/003_misc_tools.sh"

# Remove redundant packages
# shellcheck disable=SC2015
pacman -Q vi 2>/dev/null && sudo pacman -R --noconfirm vi || true
# shellcheck disable=SC2015
pacman -Q vim 2>/dev/null && sudo pacman -R --noconfirm vim || true

"${DIR}/customize_gnome/001_tilix_style.sh"
"${DIR}/customize_gnome/007_avatar.sh"

# Prepare LibreWolf/KeepassXC interoperability
mkdir ~/.mozilla ~/.librewolf
ln -s ~/.mozilla/native-messaging-hosts ~/.librewolf/native-messaging-hosts

# Set up SSH agent
# https://www.reddit.com/r/archlinux/comments/1aq97m8/gnomekeyring_14601_in_extratesting_disables/
systemctl --user enable gcr-ssh-agent.socket
mkdir -p ~/.config/environment.d/
echo "SSH_AUTH_SOCK=\${XDG_RUNTIME_DIR}/gcr/ssh" > ~/.config/environment.d/ssh_auth_socket.conf
systemctl --user start gnome-keyring-daemon.service gnome-keyring-daemon.socket

echo "Done. Log out and log in again in order to actually see the changes made."