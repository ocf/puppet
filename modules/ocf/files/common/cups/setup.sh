#!/bin/sh
# OCF config

service cups start

# Do not show network printers
cupsctl --no-remote-printers

# Remove existing printers
printers="`lpstat -p | grep ^printer | cut -d' ' -f2`"
for printer in $printers; do
  echo "Removing printer: $printer"
  lpadmin -x $printer
done

service cups stop
sleep 5

# Add new printers
#lpadmin -E -p double -D 'double-sided printing' -L 'OCF lab' -P /etc/cups/ocf.ppd -v http://printhost:631/classes/double
#lpadmin -E -p single -D 'single-sided printing' -L 'OCF lab' -P /etc/cups/ocf.ppd -v http://printhost:631/classes/single
cp /opt/share/puppet/cups/printers.conf /etc/cups/printers.conf
mkdir -p /etc/cups/ppd
cp /opt/share/puppet/cups/ocf.ppd /etc/cups/ppd/double.ppd
cp /opt/share/puppet/cups/ocf.ppd /etc/cups/ppd/single.ppd

service cups start
