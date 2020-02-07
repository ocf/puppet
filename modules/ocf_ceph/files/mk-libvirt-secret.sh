#!/bin/bash
set -euo pipefail

uuid="$(virsh secret-define --file /etc/ceph/libvirt-secret.xml | cut -d ' ' -f 2)"
secret="$(ceph auth get-key client.libvirt)"
virsh secret-set-value --secret $uuid --base64 "$secret"
