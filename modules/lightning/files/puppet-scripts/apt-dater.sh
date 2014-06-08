#!/bin/sh

set -e

subnet='169.229.10.0/24'
exclude_hosts='169.229.10.1,169.229.10.253'
keytab='/root/apt-dater.keytab'
config='/root/.config/apt-dater/hosts.conf'

kinit -t "$keytab" apt-dater

cat /dev/null > "$config"

hosts="`nmap -sn -oG - --system-dns --exclude $exclude_hosts $subnet \
| grep ^Host | cut -d' ' -f3 | cut -f1 | tr -d '()' | sed 's/.ocf.berkeley.edu//gI'`"
echo '[ocf]' >> "$config"; echo -n 'Hosts=' >> "$config"
for host in $hosts; do
  echo -n "apt-dater@$host;"
done >> "$config"

apt-dater -r > /dev/null
apt-dater
