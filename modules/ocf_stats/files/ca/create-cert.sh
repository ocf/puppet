#!/bin/bash
# Generates a private key and signed certificate for the given host.
#
# The key and cert will be stored in certs/$HOST/. The csr is deleted.
# Keys are signed for 10 years by this CA, which is not actually trusted
# by anything except the stat reporting system.
#
# Use the FQDN for the hostname, e.g. eruption.ocf.berkeley.edu
# usage: ./create-cert.sh HOSTNAME

if [ "$UID" -ne 0 ]; then
	echo "You are not root."
	exit 1
fi

HOST="$1"
HOST_DIR="certs/$HOST"

if [ -z "$HOST" ]; then
	echo "usage: $0 <hostname>"
	exit 2
fi

# create directory for the host
mkdir -p "$HOST_DIR"
chmod 700 "$HOST_DIR"

# generate key and csr
SUBJECT="/C=US/ST=California/L=Berkeley/O=Open Computing Facility/\
O=University of California, Berkeley/OU=Lab Stats/CN=$HOST"

openssl genrsa -out "$HOST_DIR/$HOST.key" 4096
openssl req -new -key "$HOST_DIR/$HOST.key" -out "$HOST_DIR/$HOST.csr" -subj "$SUBJECT"

# sign the certificate
openssl ca -config openssl.cnf -batch -notext \
	-in "$HOST_DIR/$HOST.csr" -out "$HOST_DIR/$HOST.crt"

# remove the CSR
rm "$HOST_DIR/$HOST.csr"

# set restrictive permissions on the files, just to be safe
chmod 400 $HOST_DIR/*

echo ""
echo "==============================================================================="
echo ""
echo "A key and certificate have been generated for you:"
echo ""
echo "  - $HOST_DIR/$HOST.key"
echo "  - $HOST_DIR/$HOST.crt"
echo ""
echo "These should be copied to private on lightning to be deployed to the new desktop."
