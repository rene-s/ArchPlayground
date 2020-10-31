#!/usr/bin/env bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DIR" || exit
. ../lib/sharedfuncs.sh

bail_on_user

PRODUCT_NAME=$(cat /sys/devices/virtual/dmi/id/product_name)

loadkeys de-latin1

# determine disk to install on
print_info "Available storage devices:"

lsblk -o KNAME,TYPE,SIZE,MODEL | grep disk

read -r -p "Disk to install on (for example '/dev/nvme0n1' or '/dev/sda'): " DISK

if [[ $DISK == *"nvme"* ]]; then
  DISK_SYSTEM="${DISK}p2"
else
  DISK_SYSTEM="${DISK}2"
fi

# check for nvme devices
lsblk | grep nvme
RET=$?
[[ RET -eq 0 ]] && HAS_NVME=1 || HAS_NVME=0

# check for nvidia graphics; lspci hangs when nouveau is currently loaded, so use a different method for determination
# see https://bugs.archlinux.org/task/45825
lsmod | grep nouveau
RET=$?
[[ $RET -eq 0 ]] && HAS_NVIDIA=1 || HAS_NVIDIA=0

set -e

# Set vars
SYS="BIOS"

if [ -d /sys/firmware/efi ]; then
  SYS="UEFI"
fi

print_info "This is a ${SYS} system."

# Bootstrap Arch
print_info "Please wait!"

# Update time
print_info "Update time"
timedatectl set-ntp true

nano /etc/pacman.d/mirrorlist     # manually select a mirror. @todo Select automatically
read -r -p "Host name: " HOSTNAME # have the interaction aggregated
pacstrap /mnt base base-devel parted btrfs-progs f2fs-tools ntp git dmidecode hwdetect mkinitcpio linux lvm2 zsh linux-firmware nano acpid dhcpcd
cp /etc/pacman.d/mirrorlist /mnt/etc/pacman.d/mirrorlist # save fast mirrorlist for later

# Generate fstab
print_info "Generating fstab"
genfstab -U /mnt >>/mnt/etc/fstab

# Install Intel microcode
print_info "Install Intel microcode..."
arch_chroot "pacman -S --noconfirm intel-ucode syslinux grub"

# Update timezone and system time
print_info "Setting time and time zones..."
arch_chroot "ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime"
hwclock --systohc

# Setup locales and keymap
print_info "Setup locales and keymap..."
echo "en_US.UTF-8 UTF-8" >/mnt/etc/locale.gen
echo "de_DE@euro ISO-8859-15" >>/mnt/etc/locale.gen
echo "de_DE.UTF-8 UTF-8" >>/mnt/etc/locale.gen

echo "LANG=de_DE.UTF-8" >/mnt/etc/locale.conf
echo "KEYMAP=de-latin1" >/mnt/etc/vconsole.conf

arch_chroot "locale-gen"

# Basic network setup
print_info "Basic network setup..."
echo "${HOSTNAME}" >/mnt/etc/hostname
echo "127.0.0.1 localhost.localdomain localhost" >/mnt/etc/hosts
echo "::1 localhost.localdomain localhost" >>/mnt/etc/hosts
echo "127.0.1.1 ${HOSTNAME}.localdomain ${HOSTNAME}" >>/mnt/etc/hosts

#If you use encryption LUKS change the APPEND line to use your encrypted volume:
SYSTEM_UUID=$(blkid -s UUID -o value "${DISK_SYSTEM}")
print_info "Found UUID ${SYSTEM_UUID} for disk ${DISK_SYSTEM}!"

# Setup /mnt/etc/mkinitcpio.conf; add "encrypt" and "lvm" hooks
sed -i -- "s/^HOOKS=/#HOOKS=/g" /mnt/etc/mkinitcpio.conf
sed -i -- "s/^MODULES=/#MODULES=/g" /mnt/etc/mkinitcpio.conf
echo 'HOOKS="base udev autodetect modconf block keyboard keymap encrypt lvm2 filesystems fsck"' >>/mnt/etc/mkinitcpio.conf

MODULES=""

if [ $HAS_NVME -eq 1 ]; then
  MODULES="nvme"
fi

arch_chroot "pacman -Ssy"

if [ $HAS_NVIDIA -eq 1 ]; then
  MODULES="${MODULES} nouveau"
  arch_chroot "pacman -S --noconfirm xf86-video-nouveau nvidia nvidia-settings nvidia-utils"

  NVIDIA_CONF="/mnt/etc/X11/xorg.conf.d/20-nvidia.conf"

  echo "Section \"Device\"" >$NVIDIA_CONF
  echo "  Identifier \"Nvidia Card\"" >>$NVIDIA_CONF
  echo "  Driver \"nvidia\"" >>$NVIDIA_CONF
  echo "  VendorName \"NVIDIA Corporation\"" >>$NVIDIA_CONF
  echo "  Option \"NoLogo\" \"true\"" >>$NVIDIA_CONF
  echo "  #Option \"UseEDID\" \"false\"" >>$NVIDIA_CONF
  echo "  #Option \"ConnectedMonitor\" \"DFP\"" >>$NVIDIA_CONF
  echo "  # ..." >>$NVIDIA_CONF
  echo "EndSection" >>$NVIDIA_CONF
fi

echo "MODULES=\"${MODULES}\"" >>/mnt/etc/mkinitcpio.conf

arch_chroot "mkinitcpio -p linux"

if [ $SYS == "UEFI" ]; then
  print_info "UEFI setup..."

  # PRODUCT_NAME=4180W15=Lenovo T420
  sed -i -- "s/^GRUB_CMDLINE_LINUX_DEFAULT=\"loglevel=3 quiet\"/GRUB_CMDLINE_LINUX_DEFAULT=\"cryptdevice=UUID=${SYSTEM_UUID}:lvm loglevel=3 quiet\"/g" /mnt/etc/default/grub
  sed -i -- "s/^GRUB_TIMEOUT=5/GRUB_TIMEOUT=1/g" /mnt/etc/default/grub

  arch_chroot "pacman -S --noconfirm efibootmgr dosfstools gptfdisk"
  mkdir -p /mnt/boot/grub/locale
  cp /usr/share/locale/en\@quot/LC_MESSAGES/grub.mo /mnt/boot/grub/locale/en.mo

  mkdir -p /mnt/hostrun
  mount --bind /run /mnt/hostrun

  arch_chroot "\
        mkdir -p /run/lvm; \
        mount --bind /hostrun/lvm /run/lvm; \
        grub-mkconfig -o /boot/grub/grub.cfg; \
        grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=arch_grub --recheck --debug \
    "

  # Hinweis: Falls grub-install den Bootmenüeintrag nicht erstellen kann und eine Fehlermeldung ausgegeben wurde, folgenden Befehl ausführen um den UEFI-Bootmenüeintrag manuell zu erstellen:
  #efibootmgr -q -c -d /dev/sda -p 1 -w -L "GRUB: Arch-Linux" -l '\EFI\arch_grub\grubx64.efi'

  echo "\\\EFI\\\arch_grub\\\grubx64.efi" >/mnt/boot/startup.nsh
else
  # Install boot loader
  print_info "Install BIOS boot loader..."
  mkdir -p /mnt/boot/syslinux
  arch_chroot "extlinux --install /boot/syslinux"
  cat /mnt/usr/lib/syslinux/bios/mbr.bin >"${DISK}"
  cp /mnt/usr/lib/syslinux/bios/libcom32.c32 /mnt/usr/lib/syslinux/bios/menu.c32 /mnt/usr/lib/syslinux/bios/libutil.c32 /mnt/boot/syslinux/

  # Create SysLinux config
  CFG_SYSLINUX=/mnt/boot/syslinux/syslinux.cfg

  echo "" >>$CFG_SYSLINUX
  echo "LABEL Schmidt_DevOps_Arch" >>$CFG_SYSLINUX
  echo "    MENU LABEL Schmidt_DevOps_Arch" >>$CFG_SYSLINUX
  echo "    LINUX ../vmlinuz-linux" >>$CFG_SYSLINUX
  echo "    APPEND root=/dev/mapper/SDOVG-rootlv cryptdevice=UUID=\"${SYSTEM_UUID}\":lvm rw" >>$CFG_SYSLINUX
  echo "    INITRD ../initramfs-linux.img" >>$CFG_SYSLINUX

  echo "" >>$CFG_SYSLINUX
  echo "LABEL Schmidt_DevOps_Arch_No_Gui" >>$CFG_SYSLINUX
  echo "    MENU LABEL Schmidt_DevOps_Arch_No_Gui" >>$CFG_SYSLINUX
  echo "    LINUX ../vmlinuz-linux" >>$CFG_SYSLINUX
  echo "    APPEND root=/dev/mapper/SDOVG-rootlv cryptdevice=UUID=\"${SYSTEM_UUID}\":lvm rw systemd.unit=multi-user.target" >>$CFG_SYSLINUX
  echo "    INITRD ../initramfs-linux.img" >>$CFG_SYSLINUX

  sed -i -- "s/^DEFAULT arch/DEFAULT Schmidt_DevOps_Arch/g" $CFG_SYSLINUX # Make SDO/Arch flavour the default
  sed -i -- "s/^TIMEOUT [0-9]*/TIMEOUT 10/g" $CFG_SYSLINUX                # do not wait for user input so long
fi

# Set up /etc/issue
# shellcheck disable=SC2028
echo "Schmidt DevOps \r (\l) -- setup on: $(date)" >/mnt/etc/issue

pacman -Ssy >/dev/null
pacman -S --noconfirm dmidecode
arch_chroot "pacman -S --noconfirm bwm-ng dmidecode git iotop linux-headers mc namcap openssh p7zip diffutils base-devel htop reflector"
arch_chroot "reflector --country France --country Germany --age 12 --protocol https --sort rate --save /etc/pacman.d/mirrorlist"

# Set up users
print_info "Set up users:"

echo "%wheel ALL=(ALL) ALL" >>/mnt/etc/sudoers

arch_chroot "useradd -m -g users -G wheel re"
arch_chroot "useradd -m -g users -G wheel st"

configure_existing_user 'root'

# @fixme This is untested yet. Will be useful for etckeeper.
arch_chroot "\
    git config --global user.email \"root@localhost\"; \
    git config --global user.name \"root\" \
"

configure_existing_user 're'
configure_existing_user 'st'

# Move the install scripts onto the new disk so the user has not have to download the scripts twice."
mkdir -p "/mnt/usr/local/share/tmp"
mv /root/rene-s-ArchPlayground-* /mnt/usr/local/share/tmp/ArchPlayground

# Kernel modules
echo "" >/mnt/etc/modules-load.d/sdo-modules.conf

if [ $HAS_NVIDIA -eq 1 ]; then
  echo "nvidia" >>/mnt/etc/modules-load.d/sdo-modules.conf
fi

if [ "$PRODUCT_NAME" == "P640RF" ]; then
  echo "#tuxedo-wmi" >>/mnt/etc/modules-load.d/sdo-modules.conf
fi

echo "virtio-net" >>/mnt/etc/modules-load.d/sdo-modules.conf

# Finish
print_info "Done."
print_info "Reboot and remove the installation media."
print_info "Then continue with /usr/local/share/tmp/ArchPlayground/system/03_post_base_install.sh"
