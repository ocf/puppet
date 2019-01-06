class ocf_prometheus {
  include ocf_prometheus::alertmanager
  include ocf_prometheus::proxy
  include ocf_prometheus::server
}
