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
$ cd /usr/local/share
$ curl -L "sdo.sh/l/arch_inst" --output - | tar xz
```

## Step 1: Set user credentials

```bash
$ cd /usr/local/share/rene-s-ArchPlayground*/x86_64/archinstall
$ cp creds.dist.json creds.json
# customize <root password>, <user password>, <username>, save with CTRL+O, exit with CTRL+X:
$ nano creds.json 
```

## Step 2: Run archinstall

```bash
# run this single line command and follow the instructions:
$ archinstall \
--config=$(pwd)/config.json \
--creds=$(pwd)/creds.json \
--disk_layouts=$(pwd)/disk_layouts.json

# if successful:
$ poweroff # and then remove the Arch Linux ISO boot image from the machine/VM
```

After a booting the machine you should be able to log into a very basic Arch Linux system.

For further setup and customization, look at the optional steps mentioned below.

# Optional steps

Note that many scripts are not idempotent! All files are located
within `./optional`. Call them for example like this:

```bash 
$ sh ./optional/<script_name> 
```

Note that all script commands are 1 line only.

| Script                     | Idempotent | Description                                         |
|----------------------------|------------|-----------------------------------------------------|
| `setup_luks_disk.sh`       | No         | Encrypts a secondary disk and configures auto-mount |
| `setup_user.sh <username>` | No         | Configures a user account.                          |
| `setup_virtualbox.sh`      | Yes        | Configures a VirtualBox host or guest               |
| `setup_aur.sh`             | Yes        | Installs yay                                        |
| `setup_gnome.sh`           | Yes        | Installs GNOME                                      |
| `customize_root_user.sh`   | No         | Customizes root account                             |
| `customize_system.sh`      | Yes        | Generic system customization                        |
 | `customize_gnome.sh`       | No         | GNOME customization. Run from within GNOME.         |

# Links

1. Source: https://github.com/archlinux/archinstall/blob/master/examples/config-sample.json

# TODO

1. Default btrfs subvolume layout is suboptimal, see https://github.com/archlinux/archinstall/issues/781
2. GNOME customization needs to be adapted from legacy.
3. All scripts should be idempotent.
4. All scripts should be able to run without interaction.
5. `setup_user.sh` needs to be split up into setup and customization.