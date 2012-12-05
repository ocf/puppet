#!/bin/sh

read -p 'Your username: ' user
echo 'List of hosts (leave off domain) to generate principals for, separated by spaces:'
read hostnames

cd /opt/puppet/shares/private
for host in $hostnames; do
  mkdir -p $host
  echo "Creating host/$host.lab.ocf.berkeley.edu and host/$host.ocf.berkeley.edu principals and keytab"
  /usr/sbin/kadmin -p $user/admin add -r --use-defaults host/$host.lab.ocf.berkeley.edu host/$host.ocf.berkeley.edu
  echo "Exporting host/$host.lab.ocf.berkeley.edu and host/$host.ocf.berkeley.edu keytab"
  rm -f $host/krb5.keytab
  /usr/sbin/kadmin -p $user/admin ext_keytab -k $host/krb5.keytab host/$host.lab.ocf.berkeley.edu host/$host.ocf.berkeley.edu
done

chown -R puppet:puppet /opt/puppet/shares/private
chmod -R u=rX,g=,o= /opt/puppet/shares/private
