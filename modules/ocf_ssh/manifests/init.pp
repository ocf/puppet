class ocf_ssh {
  include ocf_ssl

  include ocf_ssh::nfs
  include ocf_ssh::legacy
  include ocf_ssh::hostkeys
  include ocf_ssh::webssh
}
