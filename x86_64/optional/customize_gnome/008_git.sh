#!/usr/bin/env bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DIR" || exit
. "${DIR}/../../lib/sharedfuncs.sh"
bail_on_root

# Configure git
read -r -p "Enter your email address: " email
read -r -p "Enter your name: " nameofuser

git config --global user.email "${email}"
git config --global user.name "${nameofuser}"

sudo chfn -f "${nameofuser}" "$USER"                        # Set name of user