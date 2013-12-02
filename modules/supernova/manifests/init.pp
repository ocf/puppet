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

  # provide logrotate rule for account creation scripts
  file { '/etc/logrotate.d/account-creation':
    ensure => file,
    source => 'puppet:///modules/supernova/logrotate/account-creation';
  }
}
