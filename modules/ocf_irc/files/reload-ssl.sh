#!/bin/bash
set -euo pipefail

# Send a signal to the server to make it reload certs

pid=`pgrep inspircd`
echo "Reloading certs for inspircd pid: $pid"
kill -SIGUSR1 $pid
