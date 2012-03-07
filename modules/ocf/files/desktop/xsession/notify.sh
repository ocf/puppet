#!/bin/sh

ssh="ssh -o ConnectTimeout=2 -o BatchMode=yes -n -T ssh"
notify_send="notify-send --expire-time=30000 --icon=/opt/share/xsession/backgrounds/ocf_logo_borderless.png"

lab_users="`parallel-ssh --hosts /opt/share/puppet/desktop_list --timeout 2 -i who | grep \(\: | cut -d' ' -f1 | grep -vFx $USER`"
if [ -n "$lab_users" ]; then
  lab_staff="`for i in $lab_users; do groups $i; done | grep -Fw ocfstaff | cut -d' ' -f1 | sort -u`"
  if [ -n "$lab_staff" ]; then
    lab_names="`for i in $lab_staff; do finger -ms $i; done | grep -v ^Login | awk '{print $2}' | sort -u | tr '\n' ',' | sed -e 's/,$//g' -e 's/,/, /g'`"
    $notify_send "Say hi to OCF staffer(s) in lab:
$lab_names"
  fi
fi

if $ssh "grep -Fx $USER /var/mail/etc/quota" > /dev/null; then
  $notify_send "OCF email inbox is over quota"
fi

while true; do
  balance=`$ssh "pkusers --list $USER" | grep "Account balance" | cut -d':' -f2 | cut -d'.' -f1 | tr -d -c '[:digit:]'`
  if [ -n $balance ] && ( [ -z $old_balance ] || [ $balance -ne $old_balance ] ); then
    $notify_send "$balance pages remaining
(as of `date '+%I:%M%P'`)"
    old_balance=$balance
  fi
  sleep 60
done
