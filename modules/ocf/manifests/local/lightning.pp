class ocf::local::lightning {

  # this is the puppet master
  package {
  'libapache2-mod-passenger':
  ;
  'puppetmaster-passenger':
    ensure  => latest,
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
  # Puppet manifest help
  package { [ 'puppet-lint', 'vim-puppet' ]: }

  # Hiera, PyYAML, and YAML validator
  package { [ 'hiera', 'python-yaml', 'kwalify' ]: }

  # automatic rebase for git pull in new repositories
  file { '/etc/gitconfig':
    content => "[branch]\nautosetuprebase = always",
  }

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
      ensure  => directory;
    # provide alternate environments
    '/opt/puppet/env':
      ensure  => directory;
    # provide default production environment
    '/opt/puppet/env/production':
      ensure  => symlink,
      links   => manage,
      target  => '/etc/puppet';
    # provide scripts directory
    '/opt/puppet/scripts':
      ensure  => directory,
      mode    => '0755',
      recurse => true,
      purge   => true,
      force   => true,
      source  => 'puppet:///modules/ocf/local/lightning/puppet-scripts';
    # provide public external content
    '/opt/puppet/contrib':
      ensure  => directory;
    # provide private per-host shares
    '/opt/puppet/private':
      ensure  => directory,
      mode    => '0400',
      owner   => 'puppet',
      group   => 'puppet',
      recurse => true
  }

}
