# The ocf_mail::site_vhost class configures postfix to serve the virtual hosts,
# both mail forwarding (receiving) and mail submission (sending).
class ocf_mail::site_vhost {
  # Configure an "smtp" PAM service that authenticates against MySQL.
  # To test this, you can install pamtester and try:
  # $ pamtester smtp ckuehl@dev-vhost.ocf.berkeley.edu authenticate
  ocf::repackage { 'libpam-mysql':
    # https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=758660 (caused rt#5753)
    backport_on => jessie,
  }

  $mysql_ro_password = hiera('ocfmail::mysql::ro_password')

  file {
    '/etc/pam-mysql.conf':
      content   => template('ocf_mail/site_vhost/pam-mysql.conf.erb'),
      mode      => '0600',
      show_diff => false,
      require   => Ocf::Repackage['libpam-mysql'];

    '/etc/pam.d/smtp':
      source  => 'puppet:///modules/ocf_mail/site_vhost/pam',
      require => Ocf::Repackage['libpam-mysql'];
  }

  # Configure the saslauthd instance used by Postfix.
  # To test this, you can use:  (warning: password will be logged)
  # $ /usr/sbin/testsaslauthd -s smtp -u ckuehl@dev-vhost.ocf.berkeley.edu -p password -f /var/spool/postfix/saslauthd/mux
  package { 'sasl2-bin':; }

  # postfix needs the sasl group because /var/spool/postfix/saslauthd is 0710
  # and owned by root:sasl.
  user { 'postfix':
    groups  => ['postfix', 'sasl'],
    require => Package['postfix'],
    notify  => Service['postfix'],
  }

  service { 'saslauthd':
    require => Package['sasl2-bin'],
  }

  augeas { '/etc/default/saslauthd':
    lens    => 'Shellvars.lns',
    incl    => '/etc/default/saslauthd',
    changes =>  [
      'set START yes',
      'set DESC \'"OCF mail virtual host authentication"\'',
      'set MECHANISMS pam',
      'set OPTIONS \'"-r -c -m /var/spool/postfix/saslauthd"\'',
    ],
    notify  => Service['saslauthd'],
    require => Package['sasl2-bin'];
  }

  # Postfix config to talk to SASL
  # To test this, you can use:  (warning: password will be logged)
  # $ echo -ne '\000ckuehl@dev-vhost.ocf.berkeley.edu\000password' | openssl base64
  # $ openssl s_client -connect localhost:25 -starttls smtp
  # EHLO localhost
  # AUTH PLAIN [string from openssl]
  package { 'postfix-mysql':; }

  file {
    '/etc/postfix/sasl/smtp.conf':
      source  => 'puppet:///modules/ocf_mail/site_vhost/sasl_smtp.conf',
      notify  => Service['postfix'],
      require => Package['postfix'];

    '/etc/postfix/vhost':
      ensure  => directory,
      notify  => Service['postfix'],
      require => Package['postfix'];

    '/etc/postfix/vhost/trivial-table':
      source  => 'puppet:///modules/ocf_mail/site_vhost/trivial-table',
      notify  => Service['postfix'],
      require => Package['postfix'];

    # Test with:
    # $ postmap -q 'dev-vhost.ocf.berkeley.edu' mysql:/etc/postfix/vhost/mysql-alias-domains
    '/etc/postfix/vhost/mysql-alias-domains':
      content   => template('ocf_mail/site_vhost/mysql-alias-domains.erb'),
      owner     => postfix,
      mode      => '0600',
      show_diff => false,
      notify    => Service['postfix'],
      require   => Package['postfix'];

    # Test with:
    # $ postmap -q 'ckuehl@dev-vhost.ocf.berkeley.edu' mysql:/etc/postfix/vhost/mysql-alias-map
    '/etc/postfix/vhost/mysql-alias-map':
      content   => template('ocf_mail/site_vhost/mysql-alias-map.erb'),
      owner     => postfix,
      mode      => '0600',
      show_diff => false,
      notify    => Service['postfix'],
      require   => Package['postfix'];
  }
}
