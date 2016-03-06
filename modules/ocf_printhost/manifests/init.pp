class ocf_printhost {
  include ocf::tmpfs
  include ocf_ssl

  include ocf_printhost::cups
  include ocf_printhost::enforcer
}
