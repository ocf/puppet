class ocf_prometheus {
  include ocf_prometheus::alertmanager
  include ocf_prometheus::http
  include ocf_prometheus::server
}
