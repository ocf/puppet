class ocf::desktop::seti {

  package { 'boinc-client': }

  File { 
    require => Package['boinc-client'],
    notify  => Service['boinc-client'],
  }
  file {
    '/etc/boinc-client/gui_rpc_auth.cfg':
      mode    => '0640',
      group   => 'boinc',
      source  => 'puppet:///contrib/desktop/seti/gui_rpc_auth.cfg',
    ;
    '/etc/boinc-client/remote_hosts.cfg':
      content => 'lightning.ocf.berkeley.edu',
    ;
    '/var/lib/boinc-client/account_setiathome.berkeley.edu.xml':
      source => 'puppet:///contrib/desktop/seti/account_setiathome.berkeley.edu.xml',
    ;
  }

  service { 'boinc-client': }  
  
}
