#!/usr/bin/env bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DIR" || exit
. "${DIR}/../lib/sharedfuncs.sh"
bail_on_user

PRODUCT_NAME=$(dmidecode -s system-manufacturer)

if [[ "${PRODUCT_NAME}" != "Framework" ]]; then
    echo "This does not seem to be a Framework laptop, but '${PRODUCT_NAME}'."
    exit 0
fi

# https://community.frame.work/t/12th-gen-not-sending-xf86monbrightnessup-down/20605/19
echo "blacklist hid_sensor_hub" > /etc/modprobe.d/framework-als-blacklist.conf

# https://wiki.archlinux.org/title/Framework_Laptop#Intel_Wi-Fi_6E_AX210_reset/_low_throughput_/_%22Microcode_SW_error%22
echo "options iwlwifi disable_11ax=Y" > /etc/modprobe.d/iwlwifi.conf

# https://wiki.archlinux.org/title/Intel_graphics#Screen_flickering
# https://community.frame.work/t/periodic-stuttering-on-fresh-gnome-40-wayland-install-on-arch-linux/3912/6
# Check with `cat /sys/kernel/debug/dri/0/i915_edp_psr_status`
echo "options i915 enable_psr=0" > /etc/modprobe.d/i915.conf

echo "Framework laptop customization complete. You should reboot now."






























































































