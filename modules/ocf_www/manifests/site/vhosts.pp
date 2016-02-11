# TODO: document this
class ocf_www::site::vhosts {
  file {
    '/usr/local/bin/parse-vhosts':
      source  => 'puppet:///modules/ocf_www/parse-vhosts',
      mode    => '0755',
      require => Package['python3-ocflib'];

    '/etc/ssl/private/vhosts':
      ensure  => directory,
      source  => 'puppet:///private/ssl/vhosts',
      recurse => true,
      owner   => root,
      mode    => '0600';

    '/var/www/suexec':
      ensure  => directory,
      require => Package['apache2'];
  }
  # TODO: remove the is_array check when on Puppet >= 4
  # (stringify_facts will be off by default)
  if is_array($::ocf_vhosts) {
    ocf_www::site::vhost { $::ocf_vhosts:; }
  }
}
