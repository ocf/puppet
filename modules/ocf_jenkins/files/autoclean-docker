#!/bin/bash
# Deletes old Docker junk to keep /var/lib/docker at a resonable size.
set -euo pipefail

fs_usage() {
    df --output=pcent /var/lib/docker | sed -r 's/^ *([0-9]+)%$/\1/; t; d'
}


# Try progressively cleaning things from oldest to youngest until disk usage is
# below acceptable threshold. Start at 24 hours and work our way down by 1 hour
# steps.
# This cleans containers by creation time rather than exit time, but whatever.
for ((max_age=24; max_age>=0; max_age--)); do
    if [ "$(fs_usage)" -le 75 ]; then
        break
    fi
    echo "Cleaning Docker stuff older than ${max_age}h:"
    docker system prune -af --filter "until=${max_age}h"
    echo
done
