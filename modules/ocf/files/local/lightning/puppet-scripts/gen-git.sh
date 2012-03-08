#!/bin/sh
# OCF config

set -e

cd /etc/puppet
git init
git remote add origin /opt/puppet.git
git config receive.fsckObjects true

mkdir /opt/puppet.git && cd /opt/puppet.git
chown staff:ocfstaff .
chmod g+swX .
sudo -u staff git init --bare --shared=group
umask 002
sudo -u staff git pull /etc/puppet
sudo -u staff git config receive.fsckObjects true
sudo -u staff git config receive.denyNonFastForwards false

mkdir /etc/puppet-dev && cd /etc/puppet-dev
chown staff:ocfstaff .
chmod g+swX .
sudo -i staff git clone opt/puppet.git
