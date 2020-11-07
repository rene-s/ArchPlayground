#!/usr/bin/env bash

mkdir -p ~/.ssh
chown 0700 ~/.ssh
curl -L "https://github.com/rene-s.keys" --output ~/.ssh/authorized_keys