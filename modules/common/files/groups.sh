#!/bin/sh

# move gid range of system users and groups to prevent collisions with LDAP
sed -i -e s/FIRST_SYSTEM_UID=.*/FIRST_SYSTEM_UID=300/g \
       -e s/LAST_SYSTEM_UID=.*/LAST_SYSTEM_UID=499/g \
       -e s/FIRST_SYSTEM_GID=.*/FIRST_SYSTEM_GID=300/g \
       -e s/LAST_SYSTEM_GID=.*/LAST_SYSTEM_GID=499/g \
       -e s/FIRST_UID=.*/FIRST_UID=500/g \
       -e s/LAST_UID=.*/LAST_UID=999/g \
       -e s/FIRST_GID=.*/FIRST_GID=500/g \
       -e s/LAST_GID=.*/LAST_GID=999/g /etc/adduser.conf

# change fuse group gid to match ocf group gid
sed -i 's/fuse:x:220:/fuse:x:20:/g' /etc/group

# renumber existing system groups
for gid in 20 110; do
  new_gid=`expr $gid + 100`
  sed -i "s/:$gid:/:$new_gid:/g" /etc/group
done
