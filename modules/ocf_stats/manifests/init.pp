class ocf_stats {
  include ocf_ssl::default_bundle

  class { '::apache':
    default_vhost => false,
  }

  include ocf_stats::labstats
  include ocf_stats::munin
}
