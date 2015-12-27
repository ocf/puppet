class ocf_stats {
  include ocf_ssl

  class { '::apache':
    default_vhost => false,
    mpm_module    => 'prefork'
  }
  include '::apache::mod::php'

  include apache
  include labstats
  include munin
  include www
}
