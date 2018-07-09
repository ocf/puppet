define ocf::ssl::bundle(
  Boolean $use_lets_encrypt = true,
  Array[String] $domains = [$title],
) {
  require ocf::ssl::setup

  if $use_lets_encrypt {
    ocf::ssl::lets_encrypt { $title:
      domains => $domains,
    }

    $intermediate_source = 'puppet:///modules/ocf/ssl/lets-encrypt.crt'
    $cert_path = "/var/lib/lets-encrypt/certs/${title}/cert.pem"
    $key_path = "/var/lib/lets-encrypt/certs/${title}/privkey.pem"
    $cert_source = "file://${cert_path}"
    $key_source = "file://${key_path}"

    file {
      default:
        group     => 'ssl-cert',
        show_diff => false,
        require   => [
          Ocf::Ssl::Lets_encrypt[$title],
          File['/var/lib/lets-encrypt'],
        ];

      "/etc/ssl/private/${title}.key":
        ensure => symlink,
        links  => manage,
        target => $key_path,
        mode   => '0640';

      "/etc/ssl/private/${title}.crt":
        ensure => symlink,
        links  => manage,
        target => $cert_path,
        mode   => '0644';

      "/etc/ssl/private/${title}.intermediate":
        source => $intermediate_source,
        mode   => '0644';
    }
  } else {
    # TODO: Remove this branch once we are confident enough that using Let's
    # Encrypt certs is working well and is sustainable
    $intermediate_source = 'puppet:///modules/ocf/ssl/incommon-intermediate.crt'
    $cert_source = "puppet:///private/ssl/${title}.crt"
    $key_source = "puppet:///private/ssl/${title}.key"

    file {
      default:
        group     => 'ssl-cert',
        show_diff => false;

      "/etc/ssl/private/${title}.key":
        source => $key_source,
        mode   => '0640';

      "/etc/ssl/private/${title}.crt":
        source => $cert_source,
        mode   => '0644';

      "/etc/ssl/private/${title}.intermediate":
        source => $intermediate_source,
        mode   => '0644';
    }
  }

  # ssl bundle (cert + intermediates)
  $bundle = "/etc/ssl/private/${title}.bundle"

  # pem certificate (private key + cert + intermediates)
  $pem = "/etc/ssl/private/${title}.pem"

  concat {
    default:
      owner          => 'root',
      group          => 'ssl-cert',
      show_diff      => false,
      ensure_newline => true,
      require        => [
        File["/etc/ssl/private/${title}.key"],
        File["/etc/ssl/private/${title}.crt"],
        File["/etc/ssl/private/${title}.intermediate"],
      ];

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
