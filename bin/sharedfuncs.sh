#!/usr/bin/env bash

arch_chroot() {
    arch-chroot $MOUNTPOINT /bin/bash -c "${1}"
}
