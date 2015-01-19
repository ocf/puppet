class ocf_accounts {
  # daemontools to supervise application processes
  package { ['daemontools', 'daemontools-run']:; }

  include ocf_ssl

  include ocf_accounts::app
  include ocf_accounts::nfs
  include ocf_accounts::proxy
}
