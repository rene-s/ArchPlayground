#!/usr/bin/env bash

# Saves some typing starting archinstall script

if [[ ! -f $(pwd)/user_credentials.json ]]; then
  cp "$(pwd)/user_credentials.dist.json" "$(pwd)/user_credentials.json"
  echo "File 'user_credentials.json' does not exist. Edit with 'nano ./user_credentials.json' and try again."
  exit 0
fi

archinstall --config=$(pwd)/config.json --creds=$(pwd)/user_credentials.json --disk_layouts=$(pwd)/disk_layouts.json