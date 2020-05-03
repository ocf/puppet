class ocf::packages::fahclient {
  # Folding @ Home
  package {'fahclient':;}

  $fah_user = 'Open_Computing_Facility'
  $fah_passkey = lookup('ocf_desktop::fah_passkey')

  file {
    '/etc/fahclient/config.xml':
      content   => template('ocf/packages/fahclient/config.xml.erb'),
      show_diff => false,
      require   => Package['fahclient'],
      owner     => 'fahclient',
      mode      => '0660',
      notify    => Service['FAHClient'];
  }

  service {
    'FAHClient':
      require => Package['fahclient'];
  }
}
