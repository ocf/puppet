#!/bin/sh
# OCF config

# fix creation of system users
sed -i -e s/FIRST_SYSTEM_UID=.*/FIRST_SYSTEM_UID=300/g \
       -e s/LAST_SYSTEM_UID=.*/LAST_SYSTEM_UID=499/g \
       -e s/FIRST_SYSTEM_GID=.*/FIRST_SYSTEM_GID=300/g \
       -e s/LAST_SYSTEM_GID=.*/LAST_SYSTEM_GID=499/g \
       -e s/FIRST_UID=.*/FIRST_UID=500/g \
       -e s/LAST_UID=.*/LAST_UID=999/g \
       -e s/FIRST_GID=.*/FIRST_GID=500/g \
       -e s/LAST_GID=.*/LAST_GID=999/g /etc/adduser.conf

# fix existing system groups but keep fuse group uid if changed
sed -i -e 's/:20:/:220:/g' \
       -e 's/:102:/:202:/g' \
       -e 's/:110:/:210:/g' /etc/group
sed -i -e 's/fuse:x:220:/fuse:x:20:/g' /etc/group
