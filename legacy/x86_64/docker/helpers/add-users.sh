#!/usr/bin/env bash

echo "%wheel ALL=(ALL:ALL) ALL" >> /etc/sudoers

useradd -m -g users -G wheel re
usermod -aG network re
usermod -aG wheel re

chsh -s /usr/bin/zsh re