class ocf_apphost {
  include common::nfs
  include proxy

  file {
    '/srv/apps':
      ensure => directory,
      mode   => '0755';
  }
}
