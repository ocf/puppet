class ocf::local::lightning {

  # this is the puppet master
  package { 'puppetmaster-passenger':
    ensure  => latest,
    require => Exec['puppetlabs']
  }
  # puppet manifest help
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
      ensure  => directory;
    # provide alternate environments
    '/opt/puppet/env':
      ensure  => directory;
    # provide default production environment
    '/opt/puppet/env/production':
      ensure  => symlink,
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
