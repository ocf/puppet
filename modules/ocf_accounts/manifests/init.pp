class ocf_accounts {
  include ocf_ssl

  include ocf_accounts::app
  include ocf_accounts::proxy
}
