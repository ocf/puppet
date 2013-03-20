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

  # provide puppetmaster configuration
  file {
    # external node classifier script parses nodes.yaml
    '/etc/puppet/enc.py':
      mode    => '0755',
      source  => 'puppet:///modules/ocf/local/lightning/enc.py',
    ;
    # configure contrib and private shares
    '/etc/puppet/fileserver.conf':
      source  => 'puppet:///modules/ocf/local/lightning/fileserver.conf',
    ;
    '/etc/puppet/puppet.conf':
      content => template('ocf/local/lightning/puppet.conf.erb'),
    ;
    # mail errors and warnings about puppet runs
    '/etc/puppet/tagmail.conf':
      content => 'warning, err, alert, emerg, crit: puppet',
    ;
  }

  # Puppet manifest help
  package { [ 'puppet-lint', 'vim-puppet' ]: }

  # PyYAML, and YAML validator
  package { ['python-yaml', 'kwalify']: }

  # git configuration
  file {
    # root user ssh directory
    '/root/.ssh':
      ensure  => directory,
      mode    => '0700',
    ;
    # root user private key used to deploy to github
    '/root/.ssh/id_rsa':
      mode    => '0700',
      source  => 'puppet:///private/id_rsa',
    ;
    # bare repo at /opt/puppet, force FF, github remote
    '/opt/puppet/.git/config':
      source  => 'puppet:///modules/ocf/local/lightning/git/config',
    ;
    # post-receive hook deploys environment and pushes to github
    '/opt/puppet/.git/hooks/post-receive':
      mode    => '0755',
      source  => 'puppet:///modules/ocf/local/lightning/git/post-receive',
    ;
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
      ensure  => directory,
    ;
    # provide alternate environments
    '/opt/puppet/env':
      ensure  => directory,
    ;
    # provide scripts directory
    '/opt/puppet/scripts':
      ensure  => directory,
      mode    => '0755',
      recurse => true,
      purge   => true,
      force   => true,
      source  => 'puppet:///modules/ocf/local/lightning/puppet-scripts',
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
