class common::firehol {

  file {
    # list of IANA reserved IP address ranges
    '/etc/firehol/RESERVED_IPS':
      content => "0.0.0.0/8\n10.0.0.0/8\n240.0.0.0/4",
    ;
    # filter out iptables warnings from syslog
    # requires FIREHOL_LOG_PREFIX="firehol: " in /etc/firehol/firehol.conf
    '/etc/rsyslog.d/firehol.conf':
      content => ':msg, regex, "^\[ *[0-9]*\.[0-9]*\] \'firehol: " ~',
    ;
  }

}
