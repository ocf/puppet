class ocf::packages::helm {

  # This is not a package, but until Helm 3 is in the Debian
  # repository we will have to download the binary manually.
  $install_path        = '/usr/bin'
  $package_name        = 'helm'
  $package_ensure      = '3.3.0'
  $repository_url      = 'https://get.helm.sh'
  $archive_name        = "${package_name}-v${package_ensure}-linux-amd64.tar.gz"
  $package_source      = "${repository_url}/${archive_name}"

  archive { $archive_name:
    path            => "/tmp/${archive_name}",
    source          => $package_source,
    extract         => true,
    extract_path    => $install_path,
    extract_command => 'tar xzf %s linux-amd64/helm --strip-components=1',
    creates         => "${install_path}/${package_name}",
    cleanup         => true,
  }
}
