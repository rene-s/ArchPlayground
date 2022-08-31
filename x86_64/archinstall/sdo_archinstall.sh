#!/usr/bin/env bash

# Saves some typing starting archinstall script

if [[ ! -f $(pwd)/creds.json ]]; then
  cp $(pwd)/creds.dist.json $(pwd)/creds.json
  echo "File 'creds.json' does not exist. Edit with 'nano ./creds.json' and try again."
  exit 0
fi

archinstall --config=$(pwd)/config.json --creds=$(pwd)/creds.json --disk_layouts=$(pwd)/disk_layouts.json