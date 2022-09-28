#!/usr/bin/env bash

# Based on github/octocatalog-diff:examples/scritp-overrides/git-extract-submodules/git-extract.sh
# (b2834b58bfd0c2f22797daccff53bcdf8cda915b)

# This script is called from lib/octocatalog-diff/catalog-util/git.rb and is used to
# archive and extract a certain branch of a git repository into a target directory.

if [ -z "$OCD_GIT_EXTRACT_BRANCH" ]; then
  echo "Error: Must declare OCD_GIT_EXTRACT_BRANCH"
  exit 255
fi

if [ -z "$OCD_GIT_EXTRACT_TARGET" ]; then
  echo "Error: Must declare OCD_GIT_EXTRACT_TARGET"
  exit 255
fi

set -euf -o pipefail
git worktree remove -f "$OCD_GIT_EXTRACT_TARGET" || true
git worktree add "$OCD_GIT_EXTRACT_TARGET" "$OCD_GIT_EXTRACT_BRANCH" --detach
( cd "$OCD_GIT_EXTRACT_TARGET" && git submodule sync --recursive && git submodule update --init --recursive )
