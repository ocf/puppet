class ocf::packages::restic {

  # This is not a package, but until newer version of Restic
  $install_path        = '/usr/local/bin'
  $package_name        = 'restic'
  $package_ensure      = '0.12.0'
  $download_url        = "https://github.com/restic/restic/releases/download/v0.12.0/${package_name}_${package_ensure}_linux_amd64.bz2"
  $archive_name        = "${package_name}-${package_ensure}_linux_amd64.bz2"

  archive { $archive_name:
    path            => "/tmp/${archive_name}",
    source          => $download_url,
    extract         => true,
    extract_path    => $install_path,
    creates         => "${install_path}/${package_name}",
    cleanup         => true,
  }
}
