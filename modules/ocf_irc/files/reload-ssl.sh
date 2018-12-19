#!/bin/bash

# Log into the IRC server and reload the SSL cert.

# Use a random nick to ensure no collisions with users on the server
username=$(pwgen --secure --no-numerals 16 1)
oper_pass=$(<"$1")

(
echo NICK $username
echo USER ocfletsencrypt 0 0 :Lets Encrypt cert reloading script
sleep 2
echo OPER ocfletsencrypt "$oper_pass"
sleep 2
echo REHASH -ssl
echo QUIT
) | telnet 127.0.0.1 6667
