# https://wiki.archlinux.de/title/yaourt#Installation

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cd $DIR

. ./sharedfuncs.sh

if [ "${USER}" == "root" ]; then
    print_danger "This script is supposed to be run as user, not as root."
    exit 1
fi

PRODUCT_NAME=`cat /sys/devices/virtual/dmi/id/product_name`

sudo pacman -S wget diffutils base-devel

cd /tmp
curl -O https://aur.archlinux.org/cgit/aur.git/snapshot/package-query.tar.gz
tar -xvzf package-query.tar.gz
cd package-query
makepkg -si

cd ..
curl -O https://aur.archlinux.org/cgit/aur.git/snapshot/yaourt.tar.gz
tar -xvzf yaourt.tar.gz
cd yaourt
makepkg -si

yaourt -S seafile-client
yaourt -S phpstorm
yaourt -S rts_bpp-dkms-git

# P640RF=Tuxedo XC1406, 4180W15=Lenovo T420
if [ $PRODUCT_NAME == "P640RF" ]; then
    yaourt -S tuxedo-wmi-dkms
    # https://www.linux-onlineshop.de/forum/index.php?page=Thread&threadID=26
    sed -i -- "s/^#tuxedo-wmi/tuxedo-wmi/g" /etc/modules-load.d/sdo-modules.conf
fi



