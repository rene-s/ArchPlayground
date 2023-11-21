#!/usr/bin/env bash

# Saves some typing starting archinstall script

if [[ ! -f $(pwd)/config.json ]]; then
  cp "$(pwd)/config.dist.json" "$(pwd)/config.json"
  echo "File 'config.json' does not exist. Edit with 'nano ./config.json' and try again."
  exit 0
fi

if [[ ! -f $(pwd)/user_credentials.json ]]; then
  cp "$(pwd)/user_credentials.dist.json" "$(pwd)/user_credentials.json"
  echo "File 'user_credentials.json' does not exist. Edit with 'nano ./user_credentials.json' and try again."
  exit 0
fi

archinstall --config="$(pwd)/config.json" --creds="$(pwd)/user_credentials.json"

cp -vR /root/rene-s-ArchPlayground* /usr/local/share/ArchPlayground