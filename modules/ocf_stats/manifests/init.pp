class ocf_stats {
  include ocf::ssl::default

  class { '::apache':
    default_vhost => false,
  }

  include ocf_stats::grafana
  include ocf_stats::labstats
  include ocf_stats::munin
  include ocf_stats::prometheus
}
