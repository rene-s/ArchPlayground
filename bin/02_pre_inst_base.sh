#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cd $DIR

. ./sharedfuncs.sh

if [ "${USER}" != "root" ]; then
    print_danger "This script is supposed to be run as root, not as user."
    exit 1
fi

# vars
MOUNTPOINT="/mnt"

loadkeys de-latin1

# determine disk to install on
print_info "Available storage devices:"

lsblk -o KNAME,TYPE,SIZE,MODEL | grep disk

read -p "Disk to install on (for example '/dev/nvme0n1' or '/dev/sda'): " DISK

if [[ $DISK == *"nvme"* ]]
then
    DISK_BOOT="${DISK}p1"
    DISK_SYSTEM="${DISK}p2"
else
    DISK_BOOT="${DISK}1"
    DISK_SYSTEM="${DISK}2"
fi

# check for nvme devices
lsblk | grep nvme
[[ $? -eq 0 ]] && HAS_NVME=1 || HAS_NVME=0

# check for nvidia graphics; lspci hangs when nouveau is currently loaded, so use a different method for determination
# see https://bugs.archlinux.org/task/45825
lsmod | grep nouveau
[[ $? -eq 0 ]] && HAS_NVIDIA=1 || HAS_NVIDIA=0

set -e

# Set vars
SYS="BIOS"

if [ -d /sys/firmware/efi ]; then
        SYS="UEFI"
fi

print_info "This is a ${SYS} system."

# Bootstrap Arch
print_info "Bootstrapping"
pacstrap /mnt base base-devel parted btrfs-progs f2fs-tools ntp wget git dmidecode

# Update time
print_info "Update time";
timedatectl set-ntp true

# Generate fstab
print_info "Generating fstab"
genfstab -U /mnt >> /mnt/etc/fstab

# Chroot into new env
print_info "Chrooting..."

# Install Intel microcode
print_info "Install Intel microcode..."
arch_chroot "pacman -S --noconfirm intel-ucode syslinux grub"

# Update timezone and system time
print_info "Setting time and time zones..."
arch_chroot "ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime"
hwclock --systohc

# Setup locales and keymap
print_info "Setup locales and keymap..."
echo "en_US.UTF-8 UTF-8" > /mnt/etc/locale.gen
echo "de_DE@euro ISO-8859-15" >> /mnt/etc/locale.gen
echo "de_DE.UTF-8 UTF-8" >> /mnt/etc/locale.gen

echo "LANG=de_DE.UTF-8" > /mnt/etc/locale.conf
echo "KEYMAP=de-latin1" > /mnt/etc/vconsole.conf

arch_chroot "locale-gen"

# Basic network setup
print_info "Basic network setup..."
HOSTNAME="newschmidtdevopsworkstationchangeme"
echo "${HOSTNAME}" >/mnt/etc/hostname
echo "127.0.0.1 localhost.localdomain localhost" >/mnt/etc/hosts
echo "::1 localhost.localdomain localhost" >>/mnt/etc/hosts
echo "127.0.1.1 ${HOSTNAME}.localdomain ${HOSTNAME}" >>/mnt/etc/hosts

# Set up mirror list
echo "Server = https://ftp.fau.de/archlinux/\$repo/os/\$arch" > /mnt/etc/pacman.d/mirrorlist
echo "Server = https://mirror.vfn-nrw.de/archlinux/\$repo/os/\$arch" >> /mnt/etc/pacman.d/mirrorlist
echo "Server = https://mirror.netcologne.de/archlinux/\$repo/os/\$arch" >> /mnt/etc/pacman.d/mirrorlist

#If you use encryption LUKS change the APPEND line to use your encrypted volume:
SYSTEM_UUID=`blkid -s UUID -o value "${DISK_SYSTEM}"`
print_info "Found UUID ${SYSTEM_UUID} for disk ${DISK_SYSTEM}!"

# Setup/mnt/etc/mkinitcpio.conf; add "encrypt" and "lvm" hooks
sed -i -- "s/^HOOKS=/#HOOKS=/g" /mnt/etc/mkinitcpio.conf
sed -i -- "s/^MODULES=/#MODULES=/g" /mnt/etc/mkinitcpio.conf
echo 'HOOKS="base udev autodetect modconf block encrypt lvm2 filesystems keyboard fsck"' >>/mnt/etc/mkinitcpio.conf

MODULES=""

if [ $HAS_NVME -eq 1 ]; then
    MODULES="nvme"
fi

arch_chroot "pacman -Ssy"

if [ $HAS_NVIDIA -eq 1 ]; then
    MODULES="${MODULES} nouveau"
    arch_chroot "pacman -S --noconfirm xf86-video-nouveau nvidia nvidia-settings nvidia-utils"
fi

echo "MODULES=\"${MODULES}\"" >>/mnt/etc/mkinitcpio.conf

arch_chroot "mkinitcpio -p linux"

if [ $SYS == "UEFI" ]; then
    print_info "UEFI setup..."

    sed -i -- "s/^GRUB_CMDLINE_LINUX_DEFAULT=\"quiet\"/GRUB_CMDLINE_LINUX_DEFAULT=\"acpi_os_name=Linux acpi_osi= acpi_backlight=vendor i8042.reset i8042.nomux i8042.nopnp i8042.noloop cryptdevice=UUID=${SYSTEM_UUID}:lvm\"/g" /mnt/etc/default/grub
    sed -i -- "s/^GRUB_TIMEOUT=5/GRUB_TIMEOUT=1/g" /mnt/etc/default/grub

    arch_chroot "pacman -S --noconfirm efibootmgr dosfstools gptfdisk"
    arch_chroot "grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=arch_grub --recheck --debug"
    mkdir -p /mnt/boot/grub/locale
    cp /usr/share/locale/en\@quot/LC_MESSAGES/grub.mo /mnt/boot/grub/locale/en.mo
    arch_chroot "grub-mkconfig -o /boot/grub/grub.cfg"

    # Hinweis: Falls grub-install den Bootmenüeintrag nicht erstellen kann und eine Fehlermeldung ausgegeben wurde, folgenden Befehl ausführen um den UEFI-Bootmenüeintrag manuell zu erstellen:
    #efibootmgr -q -c -d /dev/sda -p 1 -w -L "GRUB: Arch-Linux" -l '\EFI\arch_grub\grubx64.efi'
else
    # Install boot loader
    print_info "Install BIOS boot loader..."
    mkdir -p /mnt/boot/syslinux
    arch_chroot "extlinux --install /boot/syslinux"
    cat /mnt/usr/lib/syslinux/bios/mbr.bin > "${DISK}"
    cp /mnt/usr/lib/syslinux/bios/libcom32.c32 /mnt/usr/lib/syslinux/bios/menu.c32 /mnt/usr/lib/syslinux/bios/libutil.c32 /mnt/boot/syslinux/

    # Create SysLinux config
    CFG_SYSLINUX=/mnt/boot/syslinux/syslinux.cfg

    echo "" >> $CFG_SYSLINUX
    echo "LABEL Schmidt_DevOps_Arch" >> $CFG_SYSLINUX
    echo "    MENU LABEL Schmidt_DevOps_Arch" >> $CFG_SYSLINUX
    echo "    LINUX ../vmlinuz-linux" >> $CFG_SYSLINUX
    echo "    APPEND root=/dev/mapper/SDOVG-rootlv cryptdevice=UUID="${SYSTEM_UUID}":lvm rw" >> $CFG_SYSLINUX
    echo "    INITRD ../initramfs-linux.img" >> $CFG_SYSLINUX

    sed -i -- "s/^DEFAULT arch/DEFAULT Schmidt_DevOps_Arch/g" $CFG_SYSLINUX # Make SDO/Arch flavour the default
    sed -i -- "s/^TIMEOUT [0-9]*/TIMEOUT 10/g" $CFG_SYSLINUX # do not wait for user input so long
fi

# Set up /etc/issue
echo "Schmidt DevOps \r (\l) -- setup on: "`date` > /mnt/etc/issue

# Setup network
print_info "Setup network..."
configure_network

pacman -Ssy > /dev/null
pacman -S --noconfirm dmidecode
arch_chroot "pacman -S --noconfirm bwm-ng dmidecode git iotop linux-headers mc namcap openssh p7zip"

# Setup environment
VM=`dmidecode -s system-product-name`
if [[ $VM == "VirtualBox" ]]; then
    arch_chroot "pacman -S --noconfirm virtualbox-guest-modules-arch"
else
    arch_chroot "pacman -S --noconfirm virtualbox"
fi

# Set up users
print_info "Set up users:"

echo "%wheel ALL=(ALL) ALL" >> /mnt/etc/sudoers

arch_chroot "pacman -S --noconfirm zsh"
arch_chroot "useradd -m -g users -G wheel re"
arch_chroot "useradd -m -g users -G wheel st"

configure_existing_user 'root'
configure_existing_user 're'
configure_existing_user 'st'

# Create QT scaling wrapper; e.g. for Seafile change Exec and TryExec in /usr/share/applications/seafile.desktop to "/usr/local/bin/qt_scaled.sh"
QT_SCALING_WRAPPER="/usr/local/bin/qt_scaled.sh"

echo "#!/bin/bash" > /mnt${QT_SCALING_WRAPPER}
echo "# https://wiki.archlinux.org/index.php/environment_variables" >> /mnt${QT_SCALING_WRAPPER}
echo "export QT_STYLE_OVERRIDE=adwaita" >> /mnt${QT_SCALING_WRAPPER}
echo "export QT_AUTO_SCREEN_SCALE_FACTOR=0.99" >> /mnt${QT_SCALING_WRAPPER}
echo "exec \"\$1\"" >> /mnt${QT_SCALING_WRAPPER}

SEAFILE_SCALING_WRAPPER="/usr/local/bin/seafile-applet-scaling.sh"

echo "#!/bin/bash" > /mnt${SEAFILE_SCALING_WRAPPER}
echo "${QT_SCALING_WRAPPER} /usr/bin/seafile-applet" >> /mnt${SEAFILE_SCALING_WRAPPER}

# Kernel modules
echo "" > /mnt/etc/modules-load.d/sdo-modules.conf
echo "nvidia" >> /mnt/etc/modules-load.d/sdo-modules.conf
echo "#tuxedo-wmi" >> /mnt/etc/modules-load.d/sdo-modules.conf
echo "virtio-net" >> /mnt/etc/modules-load.d/sdo-modules.conf

# Finish
print_info "Done."
