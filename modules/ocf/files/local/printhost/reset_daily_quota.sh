#!/bin/bash

rm /etc/pykota/db/daily-database.sqlite
sqlite3 /etc/pykota/db/daily-database.sqlite < /usr/local/share/pykota/sqlite/pykota-sqlite.sql
chown lp /etc/pykota/db/daily-database.sqlite
pkprinters -a -c 1 logjam-double > /dev/null
pkprinters -a -c 1 logjam-single > /dev/null
pkprinters -a -c 1 deforestation-single > /dev/null
pkprinters -a -c 1 deforestation-double > /dev/null
