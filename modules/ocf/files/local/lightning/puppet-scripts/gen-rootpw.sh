#!/bin/sh
# OCF config

echo 'List of hosts (leave off domain) to provide root passwords for, separated by spaces:'
read hostnames

cd /opt/puppet/shares/private
for host in $hostnames; do
  echo "hostname: $host"
  mkdir -p $host
  mkpasswd -m sha-512 | tr -d '\n' > /opt/puppet/shares/private/$host/rootpw
done

chown -R puppet:puppet /opt/puppet/shares/private
chmod -R u=rX,g=,o= /opt/puppet/shares/private
