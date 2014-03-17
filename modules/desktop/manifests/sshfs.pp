class desktop::sshfs {

  require common::auth
  require common::ssh
  require desktop::xsession

  # install sshfs and libpam-mount
  package { [ 'libpam-mount', 'sshfs', 'fuse-utils' ]: }

  # change fuse group to match ocf group gid
  exec { 'fuse':
    command => 'sed -i "s/^fuse:.*/fuse:x:20:/g" /etc/group',
    unless  => 'grep "fuse:x:20:" /etc/group',
    require => Package['sshfs']
  }
  file {
    '/bin/fusermount':
      mode    => '4754',
      group   => fuse,
      require => [ Package['sshfs'], Exec['fuse'] ];
    '/etc/fuse.conf':
      group   => fuse,
      require => [ Package['sshfs'], Exec['fuse'] ];
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
