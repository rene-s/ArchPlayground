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
DISK="/dev/sda"
DISK_BOOT="${DISK}1"
DISK_SYSTEM="${DISK}2"

set -e
loadkeys de-latin1

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
ln -sf /mnt/usr/share/zoneinfo/Europe/Berlin /mnt/etc/localtime
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
HOSTNAME="sdotestsystem"
echo "${HOSTNAME}" >/mnt/etc/hostname
echo "127.0.0.1 localhost.localdomain localhost" >/mnt/etc/hosts
echo "::1 localhost.localdomain localhost" >>/mnt/etc/hosts
echo "127.0.1.1 ${HOSTNAME}.localdomain ${HOSTNAME}" >>/mnt/etc/hosts

# Install boot loader
print_info "Install boot loader..."
mkdir -p /mnt/boot/syslinux
arch_chroot "extlinux --install /boot/syslinux"
cat /mnt/usr/lib/syslinux/bios/mbr.bin > "${DISK}"
cp /mnt/usr/lib/syslinux/bios/libcom32.c32 /mnt/usr/lib/syslinux/bios/menu.c32 /mnt/usr/lib/syslinux/bios/libutil.c32 /mnt/boot/syslinux/

# Set up mirror list
echo "Server = https://ftp.fau.de/archlinux/\$repo/os/\$arch" > /etc/pacman.d/mirrorlist
echo "Server = https://mirror.vfn-nrw.de/archlinux/\$repo/os/\$arch" >> /etc/pacman.d/mirrorlist
echo "Server = https://mirror.netcologne.de/archlinux/\$repo/os/\$arch" >> /etc/pacman.d/mirrorlist
cp /etc/pacman.d/mirrorlist /mnt/etc/pacman.d/mirrorlist


if [ $SYS == "UEFI" ]; then
    pacman -S efibootmgr dosfstools gptfdisk
    arch_chroot "grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=arch_grub --recheck --debug"
    mkdir -p /mnt/boot/grub/locale
    cp /usr/share/locale/en\@quot/LC_MESSAGES/grub.mo /mnt/boot/grub/locale/en.mo
    arch_chroot "grub-mkconfig -o /boot/grub/grub.cfg"

    # Hinweis: Falls grub-install den Bootmenüeintrag nicht erstellen kann und eine Fehlermeldung ausgegeben wurde, folgenden Befehl ausführen um den UEFI-Bootmenüeintrag manuell zu erstellen:
    #efibootmgr -q -c -d /dev/sda -p 1 -w -L "GRUB: Arch-Linux" -l '\EFI\arch_grub\grubx64.efi'
fi

# Setup/mnt/etc/mkinitcpio.conf; add "encrypt" and "lvm" hooks
sed -i -- "s/^HOOKS=/#HOOKS=/g" /mnt/etc/mkinitcpio.conf
echo 'HOOKS="base udev autodetect modconf block encrypt lvm2 filesystems keyboard fsck"' >>/mnt/etc/mkinitcpio.conf

# Create SysLinux config
if [ $SYS == "BIOS" ]; then
    #If you use encryption LUKS change the APPEND line to use your encrypted volume:
    SYSTEM_UUID=`blkid -s UUID -o value "${DISK_SYSTEM}"`
    print_info "Found UUID ${SYSTEM_UUID} for disk ${DISK_SYSTEM}!"

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

arch_chroot "mkinitcpio -p linux"

# Set up root user
print_info "Set up users:"

echo "%wheel ALL=(ALL) ALL" >> /mnt/etc/sudoers

arch_chroot "pacman -S --noconfirm zsh"
arch_chroot "useradd -m -g users -G wheel re"
arch_chroot "useradd -m -g users -G wheel st"

configure_existing_user 'root'
configure_existing_user 're'
configure_existing_user 'st'

# Set up /etc/issue
echo "Schmidt DevOps \r (\l) -- setup on: "`date` > /mnt/etc/issue

# Setup network
print_info "Setup network..."
configure_network

# Move /opt because on /home is more space available
rmdir /mnt/opt
mkdir /mnt/home/.opt
arch_chroot "ln -s /home/.opt /opt"

# Finish
print_info "Done."
