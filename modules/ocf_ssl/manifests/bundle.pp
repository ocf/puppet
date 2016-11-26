define ocf_ssl::bundle(
  $intermediate_source = 'puppet:///modules/ocf_ssl/incommon-intermediate.crt',
  $cert_source = "puppet:///private/ssl/${title}.crt",
  $key_source = "puppet:///private/ssl/${title}.key",
) {
  require ocf_ssl

  file {
    default:
      group   => ssl-cert;

    "/etc/ssl/private/${title}.key":
      source  => $key_source,
      mode    => '0640';

    "/etc/ssl/private/${title}.crt":
      source  => $cert_source,
      mode    => '0644';

    "/etc/ssl/private/${title}.intermediate":
      source  => $intermediate_source,
      mode    => '0644';
  }

  # ssl bundle (cert + intermediates)
  $bundle = "/etc/ssl/private/${title}.bundle"

  concat { $bundle:
    owner => root,
    group => ssl-cert,
    mode  => '0644',

    ensure_newline => true,
  }

  concat::fragment {
    "${title}-cert":
      target => $bundle,
      source => $cert_source,
      order  => '0';

    "${title}-intermediate":
      target => $bundle,
      source => $intermediate_source,
      order  => '1';
  }
}
