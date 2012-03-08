#!/bin/sh
# OCF config

read -p 'Your username: ' user
echo 'List of hosts (leave off domain) to generate principals for, separated by spaces:'
read hostnames
read -p 'int.ocf.berkeley.edu principals only? [yn]' int

cd /opt/puppet/private
for host in $hostnames; do
  mkdir -p $host
  if [ $int = 'y' -o $int = 'Y' ]; then
    echo "Creating host/$host.int.ocf.berkeley.edu principal"
    /usr/sbin/kadmin -p $user/admin add -r --use-defaults host/$host.int.ocf.berkeley.edu
    echo "Exporting host/$host.int.ocf.berkeley.edu keytab"
    /usr/sbin/kadmin -p $user/admin ext_keytab -k $host/krb5.keytab host/$host.int.ocf.berkeley.edu
  elif [ $int = 'n' -o $int = 'N' ]; then
    echo "Creating host/$host.int.ocf.berkeley.edu and host/$host.ocf.berkeley.edu principals and keytab"
    /usr/sbin/kadmin -p $user/admin add -r --use-defaults host/$host.int.ocf.berkeley.edu host/$host.ocf.berkeley.edu
    echo "Exporting host/$host.int.ocf.berkeley.edu and host/$host.ocf.berkeley.edu keytab"
    /usr/sbin/kadmin -p $user/admin ext_keytab -k $host/krb5.keytab host/$host.int.ocf.berkeley.edu host/$host.ocf.berkeley.edu
  else
    echo "Error parsing: $int"
    exit 2
  fi
done

chown -R puppet:puppet /opt/puppet/private
chmod -R u=rX,g=,o= /opt/puppet/private
