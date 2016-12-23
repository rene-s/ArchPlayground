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

### First stage

After booting the Arch Linux live image, run

```
wget "sdo.sh/l/?arch_inst" -O - | tar xz
```

Then cd into the newly created directory and run

```
sh ./bin/pre_inst_disk.sh
sh ./bin/pre_inst_base.sh
```

After that, reboot and remove the Arch live image.

### Second stage

Log in as root, then:

```
mkdir /usr/local/share/tmp
cd /usr/local/share/tmp

git clone https://github.com/rene-s/ArchPlayground.git
cd ./ArchPlayground
sh ./bin/post_inst_desktop.sh
reboot
```

### Third stage

Log in as user, then:

```
cd /usr/local/share/tmp/ArchPlayground
sh ./bin/post_setup_user.sh
```

Log out, repeat for all other users that require setup.

## Useful links

1. https://wiki.archlinux.org/index.php/Pacman/Rosetta

