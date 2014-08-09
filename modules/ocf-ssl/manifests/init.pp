# Provides the key, certificate, and InCommon CA certificate bundle at
# /etc/ssl/private/$cert_name.{key,crt,bundle}
#
# By default, cert_name is the fully-qualified hostname
class ocf-ssl($cert_name = $::fqdn) {
  File {
    owner => root,
    group => root
  }

  file {
    "/etc/ssl/certs/incommon-intermediate.crt":
      source  => "puppet:///modules/ocf-ssl/incommon-intermediate.crt",
      mode    => 644,
      notify  => Exec['gen-bundle'];

    # private ssl
    "/etc/ssl/private/${cert_name}.key":
      source  => "puppet:///private/ssl/${cert_name}.key",
      mode    => 600,
      notify  => Exec['gen-bundle'];
    "/etc/ssl/private/${cert_name}.crt":
      source  => "puppet:///private/ssl/${cert_name}.crt",
      mode    => 644,
      notify  => Exec['gen-bundle'];
  }

  exec { 'gen-bundle':
    command =>
      "cat /etc/ssl/certs/incommon-intermediate.crt \"/etc/ssl/private/${cert_name}.crt\" > /etc/ssl/private/${cert_name}.bundle",
    creates => "/etc/ssl/private/${cert_name}.bundle",
    require => [
      File["/etc/ssl/certs/incommon-intermediate.crt"],
      File["/etc/ssl/private/${cert_name}.key"],
      File["/etc/ssl/private/${cert_name}.crt"]
    ];
  }
}
