class ocf::packages::restic {

  if $::lsbdistcodename == 'buster' {
    package { 'restic':
      ensure => 'purged',
    }
  }
  $install_path        = '/usr/local/bin'
  $package_name        = 'restic'
  $package_ensure      = '0.12.0'
  $download_url        = "https://github.com/restic/restic/releases/download/v0.12.0/${package_name}_${package_ensure}_linux_amd64.bz2"
  $archive_name        = "${package_name}-${package_ensure}_linux_amd64.bz2"

  archive {
    $archive_name:
      path            => "/tmp/${archive_name}",
      source          => $download_url,
      extract         => true,
      extract_path    => $install_path,
      extract_command => "bzcat %s > ${install_path}/${package_name}",
      creates         => "${install_path}/${package_name}",
      cleanup         => true,
  } ~>
  file {
    "${install_path}/${package_name}":
      ensure => 'present',
      mode   => '0755',
      owner  => 'root';
  }
}
