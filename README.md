# Notes

The purpose of this repo is to provide an easy way to an opinionated GNOME desktop based on Arch Linux and a LTS kernel.

While this repo is available to the public, I'm maintaining these scripts and configs mainly for myself.

Use at your own risk, this is work in progress.

# Usage

1. [Download the Arch Linux ISO image](https://www.archlinux.org/download/).
2. Create a VM in VirtualBox or whatever virtualization system you are using.
3. Boot from the Arch Linux ISO boot image.

After booting the Arch Linux ISO boot image, run

```bash
# if you have a german keyboard:
$ loadkeys de-latin1 

# download and unpack ArchPlayground scripts:
$ cd /root
$ curl -L "sdo.sh/l/arch_inst" --output - | tar xz
```

## Step 1: Set user credentials

```bash
$ cd /root/rene-s-ArchPlayground*/x86_64/archinstall

$ cp user_credentials.dist.json user_credentials.json
# customize <root password>, <user password>, <username>, save with CTRL+O, exit with CTRL+X:
$ nano user_credentials.json 

# find disk device name and manually set it in config.json
$ lsblk # note the disk name
$ cp config.dist.json config.json
$ nano config.json
```

## Step 2: Run archinstall

Run these commands and follow the instructions. 

- For disk layout, select a best-effort Btrfs layout
- Select encryption

```bash
# 
$ chmod +x ./sdo_archinstall.sh
$ ./sdo_archinstall.sh

# if successful:
$ poweroff # and then remove the Arch Linux ISO boot image from the machine/VM
```

After a reboot the machine you should be able to log into a very basic Arch Linux system.

For further setup and customization, look at the optional steps mentioned below.

# Optional steps

Note that many scripts are not idempotent! All files are located
within `./optional`. Call them for example like this:

```bash
# login as root
$ cd /usr/local/share/ArchPlayground/x86_64
$ sudo chmod +x ./optional/*.sh
$ sh ./optional/<script_name> 
```

Note that all script commands are 1 line only.

| Order | Script                        | Idempotent | Description                                         |
|-------|-------------------------------|------------|-----------------------------------------------------|
| 01    | `01_setup_user.sh <username>` | No         | Configures a user account. REBOOT afterwards        |
| 02    | `02_setup_luks_disk.sh`       | No         | Encrypts a secondary disk and configures auto-mount |
| 03    | `03_customize_root_user.sh`   | No         | Customizes root account                             |
| 04    | `04_customize_system.sh`      | Yes        | Generic system customization                        |
| 05    | `05_setup_aur.sh`             | Yes        | Installs yay                                        |
| 06    | `06_setup_gnome.sh`           | Yes        | ~~Installs GNOME~~ install additional programs      |
| 07    | `07_customize_gnome.sh`       | No         | GNOME customization. Run from within GNOME.         |
| 08    | `setup_qemu_host.sh`          | Yes        | Setup a Qemu host                                   |
| 08b   | `setup_qemu_guests.sh`        | Yes        | Setup a Qemu guest                                  |

# Manual setup

Some steps require manual interaction:

1. Check and enable TRIM support for SSDs: https://wiki.archlinux.org/title/Solid_state_drive#TRIM
2. more later

# Links

1. Source: https://github.com/archlinux/archinstall/blob/master/examples/config-sample.json

# TODO

1. Default btrfs subvolume layout is suboptimal, see https://github.com/archlinux/archinstall/issues/781
2. GNOME customization needs to be adapted from legacy.
3. All scripts should be idempotent.
4. All scripts should be able to run without interaction.
5. `setup_user.sh` needs to be split up into setup and customization.