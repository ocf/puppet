class supernova {

  package {
    # account creation dependecies
    ['python-twisted', 'python-argparse', 'python-crypto']:
    ;
  }

  service { 'rsyslog': }

  # receive remote syslog from tsunami
  file { '/etc/rsyslog.d/tsunami.conf':
    content => "if \$FROMHOST startswith 'tsunami' then /var/log/tsunami.log\n& ~\n",
    notify  => Service['rsyslog'],
  }

}
