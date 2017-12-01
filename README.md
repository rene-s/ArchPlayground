# ArchPlayground

## Purpose of this script collection

This script collection's purpose is to highly automate the installation and setup of a default Schmidt DevOps workstation. It is not intended for public use and is not easily customisable.

The collection is publicly available for review and inspiration though. If you find errors or have suggestions I would appreciate a note: https://sdo.sh/DevOps/#contact

After running the scripts, the workstation should look like this:

1. All non-volatile memory wiped
1. Set up LVM on LUKS in order to encrypt most parts of the system and still have flexibility of LVM.
1. Set up default users
1. Set up zsh environment
1. Set up GNOME3 desktop environment
1. Set up Java/Android/PHP/web development environment
1. Set up Seafile and office environment

Bear in mind though there is no proper way of customisation as the default Schmidt DevOps workstation specified by the company, not by individual employees. Please direct your suggestions to the management.

## Usage

### Preparations

1. Download the Arch Linux ISO image from https://www.archlinux.org/download/
1. Create a VM in VirtualBox or whatever you are using.
1. Boot from the ISO image.

### First stage

After booting the Arch Linux ISO image, run

```
wget "sdo.sh/l/?arch_inst" -O - | tar xz # NOTE: there are no numbers in the URL
```

Then cd into the newly created directory and run

```
sh ./system/01_pre_disk_setup.sh # NOTE: at this point, the keymap will be german
sh ./system/02_pre_base_install.sh
```

After that, reboot and remove the Arch ISO image from the VM.

### Second stage

Log in as root, then:

```
systemctl start dhcpcd.service
mkdir /usr/local/share/tmp
cd /usr/local/share/tmp

git clone https://github.com/rene-s/ArchPlayground.git 
cd ./ArchPlayground
su - <your_username>
cd /usr/local/share/tmp/ArchPlayground
sh ./system/03_post_base_install.sh
exit
sh ./system/04_post_desktop_default_install.sh
reboot
```

### Third stage

Log in as user and open a terminal. Then finish the installation:

```
cd /usr/local/share/tmp/ArchPlayground
sh ./system/05_post_desktop_default_setup.sh
```

Log out, repeat for all other users that require setup.

### Optional stage

Once the default system has been set up you may want to run one or more of these scripts:

| Name | Purpose
| ---- | -------
| ```user/setup_latex.sh``` | Sets up a LaTeX environment with "TeX Live", Koma-Script, and Kile 
| ```user/setup_luks_disk.sh``` | Encrypts and sets up a second permanent hard disk or solid state disk
| ```user/setup_programming.sh``` | Installs the default SDO software development environment for Java, PHP, and JavaScript/NodeJS

## Virtualbox and UEFI booting

In the VM settings, go to ```System > Mainboard``` and enable ```EFI```. The virtual drive must be connected to a SATA controller.

Instead of showing the boot loader right away you may get thrown to a UEFI console. Switch to FS0 by typing ```FS0```. Then start the boot loader by running ```EFI\arch_grub\grubx64.efi``` (on german keyboards backslash is the # key).

## Todo

1. Card reader does not work: https://bbs.archlinux.org/viewtopic.php?id=164210
1. Hibernation has not been set up.
1. ~~Special keys for screen brightness and touchpad do not work yet.~~
1. ~~```xrandr --listproviders``` returns 0 providers. Investigate why and determine whether the Nvidia GPU is being employed or not: https://wiki.archlinux.org/index.php/hybrid_graphics and https://wiki.archlinux.org/index.php/PRIME and https://wiki.archlinux.org/index.php/bumblebee -- ```optirun glxspheres64``` läuft nur das erste Mal schnell.~~
 

## Useful links

1. https://wiki.archlinux.org/index.php/Pacman/Rosetta
1. https://wiki.archlinux.org/index.php/Clevo_P650RS

