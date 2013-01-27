#!/bin/sh

set -e

subnet='169.229.172.64/26'
exclude_hosts='169.229.172.65,169.229.172.126'
keytab='/root/apt-dater.keytab'
config='/root/.config/apt-dater/hosts.conf'

kinit -t "$keytab" apt-dater

cat /dev/null > "$config"

hosts="`nmap -sP --system-dns --exclude $exclude_hosts $subnet \
| grep ^Host | cut -d' ' -f2 | sed 's/.ocf.berkeley.edu//gI'`"
echo '[ocf]' >> "$config"; echo -n 'Hosts=' >> "$config"
for host in $hosts; do
  echo -n "apt-dater@$host;"
done >> "$config"

apt-dater -r > /dev/null
apt-dater
