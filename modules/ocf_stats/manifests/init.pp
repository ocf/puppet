class ocf_stats {
  include ocf_ssl::default_bundle

  class { '::apache':
    default_vhost => false,
  }

  include apache
  include ocf_stats::labstats
  include ocf_stats::munin
}
