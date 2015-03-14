#!/bin/bash -e
TARGET="/srv/sites/ocf"
REMOTE="https://github.com/ocf/website.git"

if [ ! -d "$TARGET" ]; then
        git init "$TARGET"
fi

cd "$TARGET"

# update origin url
if ! git remote | grep origin > /dev/null; then
        git remote add origin "$REMOTE"
else
        git remote set-url origin "$REMOTE"
fi

# update from remote and redeploy
git fetch origin
git reset --hard origin/master
