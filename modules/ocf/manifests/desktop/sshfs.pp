class ocf::desktop::sshfs {

  require ocf::common::auth
  require ocf::common::ssh
  require ocf::desktop::xsession

  # install sshfs and libpam-mount
  package { [ 'libpam-mount', 'sshfs' ]: }

  # change fuse group to match ocf group gid
  exec { 'fuse':
    command => 'sed -i "s/^fuse:.*/fuse:x:20:/g" /etc/group',
    unless  => 'grep "fuse:x:20:" /etc/group',
    require => Package['sshfs']
  }
  file {
    '/usr/bin/fusermount':
      mode    => '4754',
      group   => fuse,
      require => [ Package['sshfs'], Exec['fuse'] ];
    '/etc/fuse.conf':
      group   => fuse,
      require => [ Package['sshfs'], Exec['fuse'] ]
  }
  service { 'fuse':
      subscribe => [ Exec['fuse'], File[ '/usr/bin/fusermount', '/etc/fuse.conf' ] ],
      require   => [ Package['sshfs'],  ]
  }

  # create directory to mount to
  file { '/etc/skel/remote':
    ensure => directory
  }

  # configure libpam_mount and add to gdm pam
  file {
    '/etc/security/pam_mount.conf.xml':
      source  => 'puppet:///modules/ocf/desktop/pam/mount.conf.xml',
      require => [ Package[ 'libpam-mount', 'sshfs' ], Service['fuse'] ];
    '/etc/pam.d/ocf-pammount':
      content => 'session optional pam_mount.so disable_interactive';
  }
  exec { 'ocf-pammount':
    command => 'echo "@include ocf-pammount" >> /etc/pam.d/gdm3',
    unless  => 'grep "^@include ocf-pammount$" /etc/pam.d/gdm3',
    require => File[ '/etc/skel/remote', '/etc/pam.d/ocf-pammount' ]
  }

}
