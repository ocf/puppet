#!/bin/sh
# OCF config

ssh="/usr/bin/ssh -o ConnectTimeout=2 -o BatchMode=yes -n -T ssh"
pssh="parallel-ssh --hosts /opt/share/puppet/desktop_list --timeout 2 -i"
notify_send="/usr/bin/notify-send --expire-time=30000 --icon=/opt/share/xsession/backgrounds/ocf_logo_borderless.png"


# display staff in lab
lab_staff="`$pssh who | grep -F \(\: | cut -d' ' -f1 | grep -vFx $USER |
           xargs --no-run-if-empty groups | grep -Fw ocfstaff | cut -d' ' -f1 | sort -u |
           xargs --no-run-if-empty finger -ms | grep -v ^Login | awk '{print $2}' | sort -u | tr '\n' ',' | sed -e 's/,$//g' -e 's/,/, /g'`"

if [ -n "$lab_staff" ]; then
    $notify_send "OCF volunteer staff in lab:
$lab_staff"
fi

# warn if email inbox over quota
if $ssh "grep -Fx $USER /var/mail/etc/quota"; then
  $notify_send "OCF email inbox is over quota"
fi

# report printing quota
while true; do
  balance=`$ssh "pkusers --list $USER" | grep -F 'Account balance' | cut -d':' -f2 | cut -d'.' -f1 | tr -d -c '[:digit:]'`
  if [ -n "$balance" ] && ( [ -z "$old_balance" ] || [ "$balance" -ne "$old_balance" ] ); then
    $notify_send "$balance pages remaining
(as of `date '+%I:%M%P'`)"
    old_balance=$balance
  fi
  sleep 60;
done
