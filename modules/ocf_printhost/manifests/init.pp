class ocf_printhost {
  include ocf::tmpfs
  include ocf_ssl::default_bundle

  include ocf_printhost::cups
  include ocf_printhost::enforcer
  include ocf::firewall::output_printers
}
