class lightning {

  # this is the puppet master
  package {
  'libapache2-mod-passenger':
  ;
  'puppetmaster-passenger':
    ensure  => present,
    require => Exec[ 'puppetlabs', 'a2enmod passenger' ],
  ;
  }
  exec {
    'a2enmod passenger':
      creates => '/etc/apache2/mods-enabled/passenger.load',
      require => Package['libapache2-mod-passenger'],
      notify  => Service['apache2'],
    ;
    'a2ensite puppetmaster':
      creates => '/etc/apache2/sites-enabled/puppetmaster',
      require => [ Package['puppetmaster-passenger'], Exec['a2enmod passenger'], ],
      notify  => Service['apache2'],
    ;
  }
  service { 'apache2':
      require => Package['puppetmaster-passenger'],
  }

  # provide puppetmaster configuration
  file {
    # configure contrib and private shares
    '/etc/puppet/fileserver.conf':
      source  => 'puppet:///modules/lightning/fileserver.conf',
    ;
    '/etc/puppet/puppet.conf':
      content => template('lightning/puppet.conf.erb'),
    ;
    # mail errors and warnings about puppet runs
    '/etc/puppet/tagmail.conf':
      content => 'warning, err, alert, emerg, crit: root',
    ;
  }

  # Puppet manifest help
  package { [ 'puppet-lint', 'vim-puppet' ]: }

  # remote package management
  package { 'apt-dater': }
  file { '/root/apt-dater.keytab':
    mode   => '0600',
    backup => false,
    source => 'puppet:///private/apt-dater.keytab'
  }

  # provide miscellaneous puppet directories
  file {
    '/opt/puppet':
      ensure  => directory,
    ;
    # provide alternate environments
    '/opt/puppet/env':
      ensure  => directory,
    ;
    # provide scripts directory
    '/opt/puppet/scripts':
      ensure  => symlink,
      links   => manage,
      target  => '/opt/share/utils/staff/puppet',
    ;
    # provide fileserver shares directory
    '/opt/puppet/shares':
      ensure  => directory,
    ;
    # provide public external content
    '/opt/puppet/shares/contrib':
      ensure  => directory,
    ;
    # provide private per-host shares
    '/opt/puppet/shares/private':
      mode    => '0400',
      owner   => 'puppet',
      group   => 'puppet',
      recurse => true
    ;
  }

}
