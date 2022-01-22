#!/usr/bin/env bash

# Configure git
read -r -p "Enter your email address: " email
read -r -p "Enter your name: " nameofuser

git config --global user.email "${email}"
git config --global user.name "${nameofuser}"

sudo chfn -f "${nameofuser}" "$USER"                        # Set name of user