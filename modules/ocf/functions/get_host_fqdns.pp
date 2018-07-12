# Get an array of FQDNs that a host is responsible for, with an optional suffix
# The '@' DNS A record needs to be handled separately since @.ocf.berkeley.edu
# doesn't really make sense as a FQDN.
#
# For example:
# If there's a host with hostname 'death' and DNS A records 'dev-vhost' and DNS
# CNAME records 'www', then this function (with the suffix 'ocf.io' would
# return ['death.ocf.io', 'dev-vhost.ocf.io', 'www.ocf.io']
function ocf::get_host_fqdns(String $suffix = 'ocf.berkeley.edu') {
  suffix(delete(concat(
    [$::hostname],
    delete($::dnsA, '@'),
    $::dnsCname,
  ), ''), ".${suffix}")
}
