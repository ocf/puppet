class ocf_accounts {
  # daemontools to supervise application processes
  package { ['daemontools', 'daemontools-run']:; }

  include ocf_accounts::proxy
  include ocf_accounts::app
}
