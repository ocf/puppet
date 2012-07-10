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
      content => template('ocf/common/apt/sources.list.erb'),
      require => Package['aptitude'];
    # override conffiles on package installation
    '/etc/apt/apt.conf.d/90conffiles':
      source  => 'puppet:///modules/ocf/common/apt/conffiles';
    # update apt list, report missing updates,  and clear apt cache and old config daily
    '/etc/cron.daily/ocf-apt':
      mode    => '0755',
      content => template('ocf/common/apt/ocf-apt.erb'),
      require => [ Package['aptitude', 'debsecan'], File['/etc/apt/sources.list'] ]
  }

  if $architecture in ['amd64', 'i386'] {
    # provide puppetlabs sources.list
    file { '/etc/apt/sources.list.d/puppetlabs.list':
      content => "deb http://apt.puppetlabs.com/ $lsbdistcodename main",
      require => Package['aptitude'],
      before  => File['/etc/cron.daily/ocf-apt']
    }
    # trust puppetlabs GPG key
    exec { 'puppetlabs':
    command => 'wget -q https://apt.puppetlabs.com/pubkey.gpg -O- | apt-key add - && aptitude update',
    unless  => 'apt-key list | grep 4BD6EC30',
    require => File['/etc/apt/sources.list']
    }
  }

  if $desktop {
    # provide desktop sources.list
    file { '/etc/apt/sources.list.d/desktop.list':
      content => "deb http://www.debian-multimedia.org/ $lsbdistcodename main non-free\ndeb http://mozilla.debian.net/ $lsbdistcodename-backports iceweasel-release",
      require => Package['aptitude'],
      before  => File['/etc/cron.daily/ocf-apt']
    }
    # trust debian-multimedia and mozilla.debian.net GPG key
    exec {
      'debian-multimedia':
        command => 'aptitude update && aptitude -o Aptitude::CmdLine::Ignore-Trust-Violations=true install deb-multimedia-keyring && aptitude update',
        unless  => 'dpkg -l deb-multimedia-keyring | grep ^ii',
        require => File['/etc/apt/sources.list','/etc/apt/sources.list.d/desktop.list'];
      'debian-mozilla':
        command => 'aptitude update && aptitude -o Aptitude::CmdLine::Ignore-Trust-Violations=true install pkg-mozilla-archive-keyring && aptitude update',
        unless  => 'dpkg -l pkg-mozilla-archive-keyring | grep ^ii',
        require => File['/etc/apt/sources.list','/etc/apt/sources.list.d/desktop.list']
    }
  }

}
