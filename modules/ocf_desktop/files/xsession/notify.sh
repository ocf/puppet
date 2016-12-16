#!/bin/sh
notify_send="/usr/bin/notify-send --expire-time=30000 --icon=/opt/share/xsession/images/ocf-color.png"

# display staff in lab
# TODO: switch this to ocfweb
lab_staff=$(curl -s https://www.ocf.berkeley.edu/stats/api/staff-in-lab)

if [ -n "$lab_staff" ]; then
  $notify_send "OCF volunteer staff in lab:
$lab_staff"
fi

# report printing quota
while true; do
  balance="`/opt/share/utils/bin/paper | grep remaining | tr -d '→' | sed -e 's/^[[:space:]]*//'`"
  if [ -n "$balance" ] && ( [ -z "$old_balance" ] || [ "$balance" != "$old_balance" ] ); then
    $notify_send "$balance
(as of `date '+%I:%M%P'`)"
    old_balance=$balance
  fi
  sleep 60;
done
