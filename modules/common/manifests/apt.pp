class common::apt ( $nonfree = false, $desktop = false, $kiosk = false ) {

  package { 'aptitude': }
  exec { 'aptitude update':
    refreshonly => true,
    require     => Package['aptitude'],
  }

  # remote package update management support
  package { [ 'apt-dater-host', 'imvirt' ]: }

  file {
    # provide sources.list
    '/etc/apt/sources.list':
      content => template('common/apt/sources.list.erb'),
      notify  => Exec['aptitude update'],
      before  => File['/etc/cron.daily/ocf-apt'],
    ;
    # update apt list, report missing updates, and clear apt cache and old config daily
    '/etc/cron.daily/ocf-apt':
      mode    => '0755',
      content => template('common/apt/ocf-apt.erb'),
      require => Package['aptitude'],
    ;
  }

  if $::architecture in ['amd64', 'i386'] {
    # provide puppetlabs sources.list
    file { '/etc/apt/sources.list.d/puppetlabs.list':
      content => "deb http://apt.puppetlabs.com/ ${::lsbdistcodename} main dependencies",
      notify  => Exec['aptitude update'],
      before  => File['/etc/cron.daily/ocf-apt'],
    }
    # trust puppetlabs GPG key
    exec { 'puppetlabs':
      command => 'wget -q https://apt.puppetlabs.com/pubkey.gpg -O- | apt-key add -',
      unless  => 'apt-key list | grep 4BD6EC30',
      notify  => Exec['aptitude update'],
      before  => File['/etc/cron.daily/ocf-apt'],
    }
  }

  if $::operatingsystem == 'Debian' and $desktop {
    # provide desktop sources.list
    file { '/etc/apt/sources.list.d/desktop.list':
      content => "deb http://mozilla.debian.net/ $::lsbdistcodename-backports iceweasel-release\ndeb http://dl.google.com/linux/chrome/deb/ stable main",
      notify  => Exec['aptitude update'],
      before  => File['/etc/cron.daily/ocf-apt'],
    }

    # trust GPG keys
    exec {
      'debian-mozilla':
        command => 'aptitude update && aptitude -o Aptitude::CmdLine::Ignore-Trust-Violations=true install pkg-mozilla-archive-keyring',
        unless  => 'dpkg -l pkg-mozilla-archive-keyring | grep ^ii',
        notify  => Exec['aptitude update'],
        require => [Package['aptitude'], File['/etc/apt/sources.list','/etc/apt/sources.list.d/desktop.list']],
        before  => File['/etc/cron.daily/ocf-apt'];

     'google-gpg':
        command => "wget -q https://dl-ssl.google.com/linux/linux_signing_key.pub -O- | apt-key add -",
        unless  => "apt-key list | grep 7FAC5991",
        notify  => Exec['aptitude update'],
        require => [Package['aptitude'], File['/etc/apt/sources.list','/etc/apt/sources.list.d/desktop.list']],
        before  => File['/etc/cron.daily/ocf-apt'];
    }
  }
}
