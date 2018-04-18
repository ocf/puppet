#!/bin/bash
# this script is usually called by lightdm during user login/logout;
# example: sudo -u ocfstats "/opt/stats/update-delay.sh" &
sleep 1 && /opt/stats/update.sh "$1"
