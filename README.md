# ArchPlayground

## Purpose of this script collection

This script collection's purpose is to highly automate the installation and setup of a default Schmidt DevOps workstation. It is not intended for public use and is not easily customizable.

After running the scripts, the workstation should look like this:

1. All non-volatile memory wiped
1. Set up LVM on LUKS in order to encrypt most parts of the system and still have flexibility of LVM.
1. Set up default users
1. Set up zsh environment
1. Set up GNOME3 desktop environment
1. Set up Java/Android/PHP/web development environment
1. Set up Seafile and office environment

## Installation

After booting the Arch Linux live CD, run

```
wget "sdo.sh/l/?arch_inst" -O - | tar xz
```

Then cd into the newly created directory and run

```
sh ./bin/arch_disk.sh
sh ./bin/arch_base.sh
```


