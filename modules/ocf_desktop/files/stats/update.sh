#!/bin/bash
# imvirt spews dmesg errors on stderr
# https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=842226
[ "$(imvirt 2>/dev/null)" == "Physical" ] || exit 0 # only count hours on desktops

CUR_USER=$(who | awk '$NF == "(:0)" { print $1 }')
DATA="state=inactive"

if [ -n "$CUR_USER" ]; then
    curl -H "Content-Type: application/json" -X POST -d "{\"user\": \"$CUR_USER\"}" \
         https://ocf.berkeley.edu/api/session/log 2>/dev/null
fi
