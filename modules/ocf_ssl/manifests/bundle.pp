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

  # pem certificate (private key + cert + intermediates)
  $pem = "/etc/ssl/private/${title}.pem"

  concat {
    default:
      owner => root,
      group => ssl-cert,

      ensure_newline => true;
    $bundle:
      mode  => '0644';
    $pem:
      mode  => '0640';
  }

  concat::fragment {
    # bundle
    "${title}-bundle-cert":
      target => $bundle,
      source => $cert_source,
      order  => '0';

    "${title}-bundle-intermediate":
      target => $bundle,
      source => $intermediate_source,
      order  => '1';

    # pem
    "${title}-pem-key":
      target => $pem,
      source => $key_source,
      order  => '0';

    "${title}-pem-cert":
      target => $pem,
      source => $cert_source,
      order  => '1';

    "${title}-pem-intermediate":
      target => $pem,
      source => $intermediate_source,
      order  => '2';
  }
}
