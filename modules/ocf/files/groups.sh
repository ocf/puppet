#!/bin/sh

# move gid range of system users and groups to prevent collisions with LDAP
sed -i -e s/FIRST_SYSTEM_UID=.*/FIRST_SYSTEM_UID=100/g \
       -e s/LAST_SYSTEM_UID=.*/LAST_SYSTEM_UID=499/g \
       -e s/FIRST_SYSTEM_GID=.*/FIRST_SYSTEM_GID=100/g \
       -e s/LAST_SYSTEM_GID=.*/LAST_SYSTEM_GID=499/g \
       -e s/FIRST_UID=.*/FIRST_UID=500/g \
       -e s/LAST_UID=.*/LAST_UID=999/g \
       -e s/FIRST_GID=.*/FIRST_GID=500/g \
       -e s/LAST_GID=.*/LAST_GID=999/g /etc/adduser.conf
