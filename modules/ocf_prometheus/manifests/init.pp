class ocf_prometheus {
  include ocf_prometheus::server
  include ocf_prometheus::alertmanager
}
