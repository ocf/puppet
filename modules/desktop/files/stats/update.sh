#!/bin/bash
[ "$(imvirt)" == "Physical" ] || exit 0 # only count hours on desktops

# workaround for bug in lightdm 1.2 where users aren't logged to utmp
# (and so we can't see them in output of w/who)
# https://bugs.launchpad.net/ubuntu/+source/lightdm/+bug/870297
CUR_USER=$(ps aux | grep "/bin/sh /opt/share/puppet/notify.sh" | \
	grep -v grep | cut -d' ' -f1 | head -n1)

DATA="state=inactive"

if [ -n "$CUR_USER" ]; then
	DATA="state=active&user=$CUR_USER"
fi

curl --cacert ca.crt --cert local.crt --key local.key \
	--data "$DATA" https://stats.ocf.berkeley.edu:444/update.cgi \
	2>/dev/null
