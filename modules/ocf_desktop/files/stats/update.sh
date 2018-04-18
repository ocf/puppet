#!/bin/bash

# state can be "active" "inactive" "cleanup"
# "active" implies a current logged-in session
# "inactive" implies the desktop isn't asleep but no one's logged in (noop)
# "cleanup" is a semi-hack to eagerly clean up sessions without relying
#   on the periodic session cleanup, or making too many calls to ocfweb
#   (and by extension, mysql)
# other files to look at: session-cleanup and session-setup in /etc/lightdm

CUR_USER=$(who | awk '$NF == "(:0)" { print $1 }')
STATE="inactive"

[[ -n "$CUR_USER" ]] && STATE="active" || STATE=${1:-"inactive"}

# use 3 states for this minor optimization: only make requests to ocfweb
# when a user is logged or once during cleanup, otherwise, stay silent
if [ "$STATE" != "inactive" ]; then
    curl -H "Content-Type: application/json" -X POST -d "{\"user\": \"$CUR_USER\", \"state\":\"$STATE\"}" \
         https://www.ocf.berkeley.edu/api/session/log 2>/dev/null
fi
