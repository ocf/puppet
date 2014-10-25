#!/usr/bin/env python3
# CGI script which accepts a webhook from GitHub and rebuilds the wiki.
# Verifies the provided HMAC over the body content to ensure requests come from
# GitHub.
#
# The body of the webhook itself is ignored.

import hashlib
import hmac
import os
import subprocess
import sys

SECRET_PATH = "/srv/ikiwiki/github.secret"

def fail():
	print("Status: 403 Forbidden")
	print()
	print("403 Forbidden")
	sys.exit(0)

# verify hmac signature with secret key
signature = os.environ.get("HTTP_X_HUB_SIGNATURE", "")

if not signature.startswith("sha1=") or len(signature) != 45:
	fail()

with open(SECRET_PATH, "rb") as secret_file:
	digest = hmac.new(secret_file.read(),
		msg=sys.stdin.read().encode("utf-8"),
		digestmod=hashlib.sha1).hexdigest()

if signature[5:] != digest:
	fail()

print("Status: 204 No Content")
print()
sys.stdout.flush()
sys.stdout.close()

with open("/dev/null", "w") as devnull:
	subprocess.call(["/srv/ikiwiki/rebuild-wiki"], stdout=devnull, stderr=devnull)
