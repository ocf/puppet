class ocf_prometheus {
  include ocf_prometheus::alertmanager
  include ocf_prometheus::irc_relay
  include ocf_prometheus::proxy
  include ocf_prometheus::pushgateway
  include ocf_prometheus::server
}
