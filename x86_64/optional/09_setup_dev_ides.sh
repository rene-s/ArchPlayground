#!/usr/bin/env bash

# This script sets up dev IDEs

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DIR" || exit
"${DIR}/../lib/sharedfuncs.sh"
bail_on_root

yay_inst_pkg intellij-idea-ultimate-edition
yay_inst_pkg webstorm
yay_inst_pkg phpstorm
yay_inst_pkg rubymine
yay_inst_pkg goland
