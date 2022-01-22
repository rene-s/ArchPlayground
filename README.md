# Notes

Just playing with Arch Linux.

While this repo is available to the public, I'm maintaining these scripts and configs mainly for myself.

Use at your own risk, this is work in progress.

# Usage

## Step 1: Run regular archinstall

Adapt the mentioned files to your liking, then run:

```bash
archinstall \
--config=$(pwd)/config.json \
--creds=$(pwd)/creds.json \
--disk_layouts=$(pwd)/disk_layouts.json
```

# Optional steps

Note that most scripts are not idempotent!

## Create and auto-mount secondary drive

```bash

```

# Links

1. Source: https://github.com/archlinux/archinstall/blob/master/examples/config-sample.json
