class sandstorm {
  package {
    [ 'apache2' ]:
    ;
    # php
    ['php5', 'php5-mysql', 'libapache2-mod-php5', 'php5-mcrypt']:
    ;
  }

  # copy ssl files
  file {
    '/etc/ssl/private/mail_ocf_berkeley_edu.crt':
      ensure  => file,
      owner   => 'root',
      group   => 'ssl-cert',
      mode    => '0640',
      backup  => false,
      source  => 'puppet:///private/ssl/mail_ocf_berkeley_edu.cer',
      notify  => Service['apache2'];
    '/etc/ssl/private/mail_ocf_berkeley_edu.key':
      ensure  => file,
      owner   => 'root',
      group   => 'ssl-cert',
      mode    => '0640',
      backup  => false,
      source  => 'puppet:///private/ssl/mail_ocf_berkeley_edu.key',
      notify  => Service['apache2'];
    '/etc/ssl/private/comodo.crt':
      ensure  => file,
      owner   => 'root',
      group   => 'ssl-cert',
      mode    => '0640',
      source  => 'puppet:///private/ssl/comodo.crt',
      notify  => Service['apache2'];
  }

  # apache must subscribe to all conf files
  service { 'apache2': }
}
