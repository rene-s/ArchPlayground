#!/usr/bin/env bash

# This script improves the responsiveness of Bluetooth mice. Only works for MX Ergo at this time.
# https://wiki.archlinux.org/index.php/Bluetooth_mouse#Mouse_lag

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )";cd $DIR
. ../lib/sharedfuncs.sh

bail_on_user

FILES=`find /var/lib/bluetooth/ -name 'info' -exec grep -lH "Name=MX Ergo" {} \;`
for file in $FILES
do
  echo "Processing ${file}..."
grep -q ConnectionParameters $file || cat <<EOF >> $file
[ConnectionParameters]
MinInterval=6
MaxInterval=9
Latency=44
Timeout=216
EOF
done
