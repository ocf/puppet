export KUBECONFIG=/etc/kubernetes/admin.conf

# etcd clients require the CA and server cert or it won't trust responses.
export ETCDCTL_CA_FILE=/etc/kubernetes/pki/etcd/ca.crt
export ETCDCTL_CERT_FILE=/etc/kubernetes/pki/etcd/server.crt
# etcd client needs the server key to decrypt responses
export ETCDCTL_KEY_FILE=/etc/kubernetes/pki/etcd/server.key
# Node that the endpoint _must_ be the same name for which
# the etcd certs were generated for with kubetool. If we used
# the fqdn here, the etcd client would complain that the cert
# is issued for the hostname only.
export ETCDCTL_ENDPOINT="https://$(hostname -s):2379"
