class ocf_stats {
  include ocf::ssl::default_incommon

  class { '::apache':
    default_vhost => false,
  }

  include ocf_stats::labstats
  include ocf_stats::munin
}
