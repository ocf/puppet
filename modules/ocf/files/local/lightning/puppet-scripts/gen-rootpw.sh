#!/bin/sh
# OCF config

echo 'List of hosts (leave off domain) to provide root passwords for, separated by spaces:'
read hostnames

cd /opt/puppet/private
for host in $hostnames; do
  echo "hostname: $host"
  mkdir -p $host
  mkpasswd -m sha-512 | tr -d '\n' > /opt/puppet/private/$host/rootpw
done

chown -R puppet:puppet /opt/puppet/private
chmod -R u=rX,g=,o= /opt/puppet/private
