#!/bin/bash

CURRENT_SNAPSHOT_FILE=/opt/share/backups/current-zfs-snapshot
CURRENT_SNAPSHOT=$(cat $CURRENT_SNAPSHOT_FILE)
OFFSITE_HOST=$(cat /opt/share/backups/offsite-host)
echo "$CURRENT_SNAPSHOT"

rsnapshot -c /opt/share/backups/rsnapshot-zfs.conf sync
rsnapshot -c /opt/share/backups/rsnapshot-zfs-mysql.conf sync
rsnapshot -c /opt/share/backups/rsnapshot-zfs-git.conf sync
rsnapshot -c /opt/share/backups/rsnapshot-zfs-pgsql.conf sync

zfs-auto-snapshot --syslog --label=after-backup --keep=10 // | awk -F"," '{print $1}' | cut -c2- > $CURRENT_SNAPSHOT_FILE
NEW_SNAPSHOT=$(cat $CURRENT_SNAPSHOT_FILE)

echo "$CURRENT_SNAPSHOT"
echo "$NEW_SNAPSHOT"

syncoid -r --no-sync-snap --sendoptions "L w c" backup/encrypted/rsnapshot "$OFFSITE_HOST":data1/ocfbackup/encrypted/rsnapshot
