#!/bin/bash

CURRENT_SNAPSHOT_FILE=/opt/share/backups/current-zfs-snapshot
CURRENT_SNAPSHOT=$(cat $CURRENT_SNAPSHOT_FILE)
OFFSITE_HOST=$(cat /opt/share/backups/offsite-host)
echo "$CURRENT_SNAPSHOT"

rsnapshot -V -c /opt/share/backups/rsnapshot-zfs.conf sync
rsnapshot -V -c /opt/share/backups/rsnapshot-zfs-mysql.conf sync
rsnapshot -V -c /opt/share/backups/rsnapshot-zfs-git.conf sync
rsnapshot -V -c /opt/share/backups/rsnapshot-zfs-pgsql.conf sync

zfs-auto-snapshot --syslog --label=after-backup --keep=10 // | awk -F"," '{print $1}' | cut -c2- > $CURRENT_SNAPSHOT_FILE
NEW_SNAPSHOT=$(cat $CURRENT_SNAPSHOT_FILE)

echo "$CURRENT_SNAPSHOT"
echo "$NEW_SNAPSHOT"

if [ -t 0 ]; then
        zfs send -cRwI backup/encrypted/rsnapshot@"$CURRENT_SNAPSHOT" backup/encrypted/rsnapshot@"$NEW_SNAPSHOT" | pv | ssh "$OFFSITE_HOST" "zfs recv -d data1/ocfbackup"
else
        zfs send -cRwI backup/encrypted/rsnapshot@"$CURRENT_SNAPSHOT" backup/encrypted/rsnapshot@"$NEW_SNAPSHOT" | ssh "$OFFSITE_HOST" "zfs recv -d data1/ocfbackup"
fi
