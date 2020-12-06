define ocf::ssl::bundle(
  Array[String] $domains = [$title],
  String $owner = 'ocfletsencrypt',
  String $group = 'ssl-cert',
) {
  require ocf::ssl::setup

  ocf::ssl::lets_encrypt::dns { $title:
    domains => $domains,
    owner   => $owner,
    group   => $group,
  }

  $cert_path = "/var/lib/lets-encrypt/certs/${title}/cert.pem"
  $key_path = "/var/lib/lets-encrypt/certs/${title}/privkey.pem"
  $chain_path = "/var/lib/lets-encrypt/certs/${title}/chain.pem"
  $fullchain_path = "/var/lib/lets-encrypt/certs/${title}/fullchain.pem"
  $key_source = "file://${key_path}"
  $bundle_source = "file://${fullchain_path}"

  file {
    default:
      owner     => 'root',
      group     => 'ssl-cert',
      show_diff => false,
      require   => [
        Ocf::Ssl::Lets_encrypt::Dns[$title],
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
      ensure => symlink,
      links  => manage,
      target => $chain_path,
      mode   => '0644';

    "/etc/ssl/private/${title}.bundle":
      ensure => symlink,
      links  => manage,
      target => $fullchain_path,
      mode   => '0644';
  }

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

    $pem:
      mode  => '0640';
  }

  concat::fragment {
    "${title}-pem-bundle":
      target => $pem,
      source => $bundle_source,
      order  => '1';

    "${title}-pem-key":
      target => $pem,
      source => $key_source,
      order  => '0';
  }
}
