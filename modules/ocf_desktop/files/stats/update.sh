#!/bin/bash

# don't trigger on desktop-like VMs
[ "$(facter virtual)" == "physical" ] || exit 0

# state can be "active" "cleanup"
# "active" implies a current logged-in session
# "cleanup" triggers closing of the session
# other files to look at: session-cleanup and session-setup in /etc/lightdm

# Grab the currently active session on seat0 and extract the username only if
# it is of class "user"
CUR_SESSION=$(loginctl show-seat --value -p ActiveSession seat0)
if [ -n "$CUR_SESSION" ]; then
  CUR_USER=$(
    loginctl show-session --value -p Name -p Class "$CUR_SESSION" |
    awk 'BEGIN { FS = "\n"; RS = "\0" } $2 == "user" { print $1 }'
  )
fi

# if a user is logged in, the state is active, else, take it from argv[1]
# (used when calling update-delay.sh from the lightdm session-cleanup script)
[[ -n "$CUR_USER" ]] && STATE="active" || STATE="$1"

# when a user is logged or once during cleanup, otherwise, stay silent
if [[ -n "$STATE" ]]; then
    curl -H "Content-Type: application/json" -X POST -d "{\"user\": \"$CUR_USER\", \"state\":\"$STATE\"}" \
         https://www.ocf.berkeley.edu/api/session/log 2>/dev/null
fi
