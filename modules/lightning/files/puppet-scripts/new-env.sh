#!/bin/bash
# creates an environment for the specified user
REPO_USER="$1"
REPO_PATH="/opt/puppet/env/$REPO_USER"

if [ $EUID -ne 0 ]; then
	echo "You are not root."
	exit 1
fi

if [ -z "$REPO_USER" ]; then
	echo "usage: $0 username"
	exit 1
fi

if ! getent passwd "$REPO_USER" > /dev/null 2>&1; then
	echo "user $REPO_USER doesn't exist"
	exit 1
fi

if [ -e "$REPO_PATH" ]; then
	echo "file already exists at $REPO_PATH"
	exit 1
fi

echo "Creating new puppet env at $REPO_PATH"

git clone /opt/puppet "$REPO_PATH"
chown -R "$REPO_USER:ocf" "$REPO_PATH"
