class ocf_stats {
  class { '::apache':
    default_vhost => false,
    mpm_module    => 'prefork'
  }
  include '::apache::mod::php'

  include apache
  include ca
  include labstats
  include munin
  include www
}
