class ocf_printhost {
  include ocf::tmpfs
  include ocf::ssl::default

  include ocf_printhost::cups
  include ocf_printhost::enforcer
  include ocf::firewall::output_printers
  include ocf_printhost::firewall_input
  include ocf_printhost::monitor
}
