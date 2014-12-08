class desktop::sshfs {
  require common::auth
  require common::ssh

  # install sshfs and libpam-mount
  package {
    ['sshfs', 'fuse']:;

    # libpam-mount was removed from jessie, so we install a local version from
    # sid (TODO: install from ocf apt repo)
    'libpam-mount':
      provider => dpkg,
      source   => '/opt/share/puppet/packages/libpam-mount_2.14-1_amd64.deb',
      require  => Package['libhx28'];

    # libpam-mount dependencies because dpkg won't resolve them automatically
    ['libhx28']:;
  }

  # create directory to mount to
  file { '/etc/skel/remote':
    ensure => directory
  }

  # configure libpam_mount and add to lightdm pam
  file {
    '/etc/security/pam_mount.conf.xml':
      source  => 'puppet:///modules/desktop/pam/mount.conf.xml',
      require => [ Package[ 'libpam-mount', 'sshfs' ] ];
    '/etc/pam.d/ocf-pammount':
      content => 'session optional pam_mount.so disable_interactive';
  }
  exec { 'ocf-pammount':
    command => 'echo "@include ocf-pammount" >> /etc/pam.d/lightdm',
    unless  => 'grep "^@include ocf-pammount$" /etc/pam.d/lightdm',
    require => File[ '/etc/skel/remote', '/etc/pam.d/ocf-pammount' ]
  }
}
