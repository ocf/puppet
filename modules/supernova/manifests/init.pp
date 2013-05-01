class supernova {

  package {
    # account creation dependecies
    ['python-twisted', 'python-argparse', 'python-crypto']:
    ;
  }
  
  # receive remote syslog from tsunami
  file { '/etc/rsyslog.d/tsunami.conf':
    content => "if $fromhost startswith 'tsunami' then /var/log/tsunami.log\n& ~\n",
  }

}
