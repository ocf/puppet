#!/bin/bash
set -euo pipefail

# Log into the IRC server and reload the SSL cert.

# Use a random nick to ensure no collisions with users on the server
nick=$(pwgen --secure --no-numerals 16 1)
oper_pass=$(<"$1")

(
echo NICK $nick
echo USER ocf-cert-reload 0 0 :Lets Encrypt cert reloading script
sleep 2
echo OPER ocf-cert-reload "$oper_pass"
sleep 2
echo REHASH -ssl
echo QUIT
) | nc 127.0.0.1 6667
