# Notes

The purpose of this repo is to provide an easy way to an opinionated GNOME desktop based on Arch Linux and a LTS kernel.

While this repo is available to the public, I'm maintaining these scripts and configs mainly for myself.

Use at your own risk, this is work in progress.

# Usage

1. [Download the Arch Linux ISO image](https://www.archlinux.org/download/).
2. Create a VM in VirtualBox or whatever virtualization system you are using.
3. Boot from the ISO image.

After booting the Arch Linux ISO image, run

```bash
$ cd /root
$ curl -L "sdo.sh/l/arch_inst" --output - | tar xz
```

## Step 1: Set user credentials

`cd` into the newly created ArchPlayground directory, then:

```bash
$ cd x86_64
$ cp archinstall/creds.dist.json archinstall/creds.json
$ nano archinstall/creds.json # set passwords to your liking, save with CTRL+O, exit with CTRL+X
```

## Step 2: Run archinstall

```bash
$ archinstall \
--config=$(pwd)/config.json \
--creds=$(pwd)/creds.json \
--disk_layouts=$(pwd)/disk_layouts.json
$ reboot # only if successful of course
```

After a reboot, you should be able to log into a very basic Arch Linux system.

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