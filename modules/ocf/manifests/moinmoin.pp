class ocf::moinmoin {
  # Version number is paired with its sha256 hash
  # See https://moinmo.in/MoinMoinDownload
  $versions = {
    '1.9.10' => '4a264418e886082abd457c26991f4a8f4847cd1a2ffc11e10d66231da8a5053c',
  }

  $versions.each |String $version, String $sha256| {
    archive { "/tmp/moinmoin-${version}.tar.gz":
      ensure        => present,
      source        => "https://static.moinmo.in/files/moin-${version}.tar.gz",
      checksum      => $sha256,
      checksum_type => 'sha256',
      extract       => true,
      extract_path  => '/opt',
    }
  }
}
