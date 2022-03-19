#!/bin/bash

# don't trigger on desktop-like VMs
[ "$(facter virtual)" == "physical" ] || exit 0

# state can be "active" "cleanup"
# "active" implies a current logged-in session
# "cleanup" triggers closing of the session
# other files to look at: session-cleanup and session-setup in /etc/lightdm

# This abomination of bash scripting:
# - lists all the sessions
# - filters by seat == "seat0"
# - filters out any session whose session ID is not a number
#   (this is because display managers like lightdm create sessions like
#   c### and we don't want to report the DM as being logged in)
# - outputs the session IDs, as newline-delimited raw strings
# - runs a shell script on each session id which:
#   - gets session data
#   - checks if the session is active
#   - if so, outputs the user associated with the session
# - gets the last output user (just in case something unexpected happened
#   and we end up with more than one)
# shellcheck disable=SC2016
CUR_USER=$(loginctl list-sessions -o json | jq 'map(select(.seat == "seat0" and (try (.session | tonumber) | true)))|.[]|.session' -r | xargs -d '\n' -n 1 bash -c 'data=$(loginctl show-session "$1"); grep "^Active=yes$" >/dev/null <<<"$data" && grep -Po "(?<=^Id=).*$" <<<"$data"' -- | tail -n1)

# if a user is logged in, the state is active, else, take it from argv[1]
# (used when calling update-delay.sh from the lightdm session-cleanup script)
[[ -n "$CUR_USER" ]] && STATE="active" || STATE="$1"

# when a user is logged or once during cleanup, otherwise, stay silent
if [[ -n "$STATE" ]]; then
    curl -H "Content-Type: application/json" -X POST -d "{\"user\": \"$CUR_USER\", \"state\":\"$STATE\"}" \
         https://www.ocf.berkeley.edu/api/session/log 2>/dev/null
fi
