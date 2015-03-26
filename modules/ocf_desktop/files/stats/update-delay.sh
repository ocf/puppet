#!/bin/bash
# this script is usually called by lightdm during user login/logout;
# example: sudo -u ocfstats "/opt/stats/update-delay.sh" &
sleep 1
cd /opt/stats && /opt/stats/update.sh
