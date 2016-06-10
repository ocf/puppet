# Site-wide SSL settings
#
# An appropriate SSL setup should also use HSTS, if possible.
#
# Taken directly from the Mozilla wiki:
# https://wiki.mozilla.org/Security/Server_Side_TLS#Intermediate_compatibility_.28default.29
#
# This should be updated from time-to-time.
$ssl_ciphersuite = 'ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA:ECDHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-RSA-AES256-SHA256:DHE-RSA-AES256-SHA:ECDHE-ECDSA-DES-CBC3-SHA:ECDHE-RSA-DES-CBC3-SHA:EDH-RSA-DES-CBC3-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:DES-CBC3-SHA:!DSS'
$ssl_protocols = 'TLSv1 TLSv1.1 TLSv1.2'

# default for Apache and Nginx vhosts
Apache::Vhost {
  ssl_cipher   => $ssl_ciphersuite,
  ssl_protocol => $ssl_protocols,
}

Nginx::Resource::Vhost {
  ssl_ciphers   => $ssl_ciphersuite,
  ssl_protocols => $ssl_protocols,
  ssl_dhparam   => '/etc/ssl/dhparam.pem',
}
