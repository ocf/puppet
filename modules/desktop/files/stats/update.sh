#!/bin/bash
[ "$(imvirt)" == "Physical" ] || exit 0 # only count hours on desktops

CUR_USER=$(w | awk '$2 == ":0"' | cut -d' ' -f1)
DATA="state=inactive"

if [ -n "$CUR_USER" ]; then
	DATA="state=active&user=$CUR_USER"
fi

curl --cacert ca.crt --cert local.crt --key local.key \
	--data "$DATA" https://stats.ocf.berkeley.edu:444/update.cgi \
	2>/dev/null
