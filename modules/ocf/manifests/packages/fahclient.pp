class ocf::packages::fahclient {
  # Folding @ Home
  package {'fahclient':;}

  file {
    '/etc/fahclient/config.xml':
      source  => 'puppet:///modules/ocf/packages/fahclient/config.xml',
      require => Package['fahclient'],
      owner   => 'fahclient',
      mode    => '0664',
      notify  => Service['FAHClient'];
  }

  service {
    'FAHClient':
      require => Package['fahclient'];
  }
}
