#!/bin/bash
# imvirt spews dmesg errors on stderr
# https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=842226
[ "$(imvirt 2>/dev/null)" == "Physical" ] || exit 0 # only count hours on desktops

CUR_USER=$(who | awk '$5 == "(:0)" { print $1 }')
DATA="state=inactive"

if [ -n "$CUR_USER" ]; then
	DATA="state=active&user=$CUR_USER"
fi

curl --data "$DATA" \
    https://labstats.ocf.berkeley.edu:444/update.cgi \
	2>/dev/null
