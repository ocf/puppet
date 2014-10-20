class ocf_stats {
  class { '::apache':
    default_vhost => false;
  }

  include apache
  include ca
  include labstats
  include munin
  include www
}
