#!/usr/bin/env python3
# Accepts a webhook from GitHub, calling another script if validation is
# successful. Output designed for CGI (prints either 403 Forbidden or 204 No
# Content).
#
# Verifies the provided HMAC over the body content to ensure requests come from
# GitHub. The body of the webhook itself is ignored.
#
# Example usage from a CGI script:
#   exec webhook_cgi_exec /path/to/shared/secret my-script

import hashlib
import hmac
import os
import subprocess
import sys

def hmac_matches(msg, signature, secret):
    if not signature or not signature.startswith('sha1='):
        return False

    return signature[5:] == \
        hmac.new(secret, msg=msg, digestmod=hashlib.sha1).hexdigest()

if __name__ == '__main__':
    if len(sys.argv) < 3:
        print("usage: {} secret_path command [..]".format(sys.argv[0]))
        sys.exit(1)

    secret_path = sys.argv[1]
    command = sys.argv[2:]

    signature = os.environ.get('HTTP_X_HUB_SIGNATURE', None)
    msg = sys.stdin.read().encode('utf-8')
    with open(secret_path, 'rb') as secret_file:
        secret = secret_file.read()

    if hmac_matches(msg, signature, secret):
        print('Status: 204 No Content')
        print()
        sys.stdout.flush()
        sys.stdout.close()

        with open(os.devnull, 'w') as devnull:
            subprocess.call(command, stdout=devnull, stderr=devnull)
    else:
        print('Status: 403 Forbidden')
        print()
        print('403 Forbidden')
