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
    $::ocf_vhosts.each |Hash $tmp_vhost| {

      # Use a temporary variable to appease puppet-lint:
      # https://github.com/rodjek/puppet-lint/issues/464
      $vhost = $tmp_vhost
      ocf_www::site::vhost { $vhost[domain]:
        vhost => $vhost,
      }
    }
  }
}
