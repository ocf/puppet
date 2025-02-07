# Site-wide SSL settings
#
# An appropriate SSL setup should also use HSTS, if possible.
#
# Taken directly from the Mozilla wiki:
# https://wiki.mozilla.org/Security/Server_Side_TLS#Intermediate_compatibility_.28default.29
#
# This should be updated from time-to-time.
if Integer($facts['os']['release']['major']) >= 11 {
  $ssl_ciphersuite = 'ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256'
  $ssl_protocols = '-all +TLSv1.2 +TLSv1.3'
  $ssl_protocols_nginx = 'TLSv1.2 TLSv1.3'
} else {
  $ssl_ciphersuite = 'ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA:ECDHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-RSA-AES256-SHA256:DHE-RSA-AES256-SHA:ECDHE-ECDSA-DES-CBC3-SHA:ECDHE-RSA-DES-CBC3-SHA:EDH-RSA-DES-CBC3-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:DES-CBC3-SHA:!DSS'
  $ssl_protocols = '-all +TLSv1.2'
  $ssl_protocols_nginx = 'TLSv1.2'
}

# default for Apache and Nginx vhosts
Apache::Vhost {
  ssl_cipher   => $ssl_ciphersuite,
  ssl_protocol => $ssl_protocols,
}

Nginx::Resource::Server {
  ssl_ciphers   => $ssl_ciphersuite,
  ssl_protocols => $ssl_protocols_nginx,
  ssl_dhparam   => '/etc/ssl/dhparam.pem',
}
