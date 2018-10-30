#!/bin/bash
# state can be "active" "cleanup"
# "active" implies a current logged-in session
# "cleanup" triggers closing of the session
# other files to look at: session-cleanup and session-setup in /etc/lightdm

CUR_USER=$(who | awk '$NF == "(:0)" { print $1 }')

[[ -n "$CUR_USER" ]] && STATE="active" || STATE="$1"

FLAGS=$1

# when a user is logged or once during cleanup, otherwise, stay silent
if [[ -n "$STATE" ]]; then
    curl -H "Content-Type: application/json" -X POST -d "{\"user\": \"$CUR_USER\", \"state\":\"$STATE\", \"flags\": \"$FLAGS\"}" \
         https://www.ocf.berkeley.edu/api/session/log 2>/dev/null
fi
