class ocf_stats {
  include apache
  include ocf::ssl::default

  include ocf_stats::labstats
  include ocf_stats::munin
  include ocf_stats::prometheus
}
