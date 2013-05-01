class pollution {

  # dumper home directory
  file { '/opt/dumper':
    ensure => directory
  }
  mount { '/opt/dumper':
    ensure  => 'mounted',
    fstype  => 'ext4',
    options => 'noatime,nodev,nosuid,noexec',
    require => File['/opt/dumper']
  }

  # dumper configuration
#  file {
#    '/opt/dumper/config':
#      ensure  => directory,
#      require => Mount['/opt/dumper'];
#    '/opt/dumper/config/rsnapshot.conf':
#      source  => 'puppet:///modules/pollution/rsnapshot.conf';
#    '/opt/dumper/config/dumper.keytab':
#      mode    => 0400,
#      owner   => dumper,
#      backup  => false,
#      source  => 'puppet:///private/dumper.keytab',
#      require => Class['Ocf::Common::Pam']
#  }

  # dumper utility
  package { 'rsnapshot': }

}
