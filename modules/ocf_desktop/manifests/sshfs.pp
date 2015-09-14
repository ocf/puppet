class ocf_desktop::sshfs {
  require ocf::auth

  # install sshfs and libpam-mount
  package { ['libpam-mount', 'sshfs']: }

  # create directory to mount to
  file { '/etc/skel/remote':
    ensure => directory
  }

  # configure libpam_mount and add to lightdm pam
  file {
    '/etc/security/pam_mount.conf.xml':
      source  => 'puppet:///modules/ocf_desktop/pam/mount.conf.xml',
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
