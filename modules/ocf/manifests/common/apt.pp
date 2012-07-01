class ocf::common::apt ( $nonfree = false, $desktop = false ) {

  package { 'aptitude': }
  exec { 'aptitude update':
    refreshonly => true,
    subscribe   => File['/etc/apt/sources.list']
  }

  # debsecan reports missing security updates, do not use provided cronjob
  package { 'debsecan': }
  file { '/etc/cron.d/debsecan':
    ensure => absent
  }

  # remote package update management support
  package { [ 'apt-dater-host', 'imvirt' ]: }

  file {
    # provide sources.list
    '/etc/apt/sources.list':
      content => template('ocf/common/sources.list.erb'),
      require => Package['aptitude'];
    # override conffiles on package installation
    '/etc/apt/apt.conf.d/90conffiles':
      source  => 'puppet:///modules/ocf/common/apt/conffiles';
    # update apt list, report missing updates,  and clear apt cache and old config daily
    '/etc/cron.daily/ocf-apt':
      mode    => '0755',
      content => template('ocf/common/ocf-apt.erb'),
      require => [ Package['aptitude', 'debsecan'], File['/etc/apt/sources.list'] ]
  }

  # trust puppetlabs GPG key
  exec { 'puppetlabs':
    command => 'wget -q https://apt.puppetlabs.com/pubkey.gpg -O- | apt-key add - && aptitude update',
    unless  => 'apt-key list | grep 4BD6EC30',
    require => File['/etc/apt/sources.list']
  }

  if $desktop {
    # trust debian-multimedia and mozilla.debian.net GPG key
    exec {
      'debian-multimedia':
        command => 'aptitude update && aptitude -o Aptitude::CmdLine::Ignore-Trust-Violations=true install deb-multimedia-keyring && aptitude update',
        unless  => 'dpkg -l deb-multimedia-keyring | grep ^ii',
        require => File['/etc/apt/sources.list'];
      'debian-mozilla':
        command => 'aptitude update && aptitude -o Aptitude::CmdLine::Ignore-Trust-Violations=true install pkg-mozilla-archive-keyring && aptitude update',
        unless  => 'dpkg -l pkg-mozilla-archive-keyring | grep ^ii',
        require => File['/etc/apt/sources.list']
    }
  }

}
