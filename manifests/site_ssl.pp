# Site-wide SSL settings
#
# An appropriate SSL setup should also use HSTS, if possible.
#
# Taken directly from the Mozilla wiki:
# https://wiki.mozilla.org/Security/Server_Side_TLS#Intermediate_compatibility_.28default.29
#
# This should be updated from time-to-time.
$ssl_ciphersuite= 'TLS_AES_128_GCM_SHA256:TLS_AES_256_GCM_SHA384:TLS_CHACHA20_POLY1305_SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384'
$ssl_protocols = 'TLSv1.2'

# default for Apache and Nginx vhosts
Apache::Vhost {
  ssl_cipher   => $ssl_ciphersuite,
  ssl_protocol => $ssl_protocols,
}

Nginx::Resource::Server {
  ssl_ciphers   => $ssl_ciphersuite,
  ssl_protocols => $ssl_protocols,
  ssl_dhparam   => '/etc/ssl/dhparam.pem',
}
