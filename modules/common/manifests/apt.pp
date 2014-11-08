class common::apt ( $desktop = false ) {
  package { ['aptitude', 'apt-dater-host', 'imvirt']: }

  class { '::apt':
    purge_sources_list   => true,
    purge_sources_list_d => true;
  }

  case $::operatingsystem {
    'Debian': {
      $repos = 'main contrib non-free'

      apt::source {
        'debian':
          location  => 'http://mirrors/debian/',
          release   => $::lsbdistcodename,
          repos     => $repos;

        'debian-security':
          location  => 'http://mirrors/debian-security/',
          release   => "${::lsbdistcodename}/updates",
          repos     => $repos;
      }

      if $::lsbdistcodename == 'wheezy' {
        apt::source { 'debian-updates':
          location  => 'http://mirrors/debian/',
          release   => "${::lsbdistcodename}-updates",
          repos     => $repos;
        }

        # XXX: we use a _different_ hostname from the regular archive because
        # the puppetlabs apt module uses hostname-based apt pinning, which
        # causes _all_ packages to be pinned at equal priority
        class { 'apt::backports':
          location => 'http://mirrors.ocf.berkeley.edu/debian/';
        }
      }
    }

    'Ubuntu': {
      $repos = 'main restricted universe multiverse'

      apt::source {
        'ubuntu':
          location  => 'http://mirrors/ubuntu/',
          release   => $::lsbdistcodename,
          repos     => $repos;

        'ubuntu-security':
          location  => 'http://mirrors/ubuntu/',
          release   => "${::lsbdistcodename}-security",
          repos     => $repos;

        'ubuntu-updates':
          location  => 'http://mirrors/ubuntu/',
          release   => "${::lsbdistcodename}-updates",
          repos     => $repos;
      }

      # XXX: we use a _different_ hostname from the regular archive because
      # the puppetlabs apt module uses hostname-based apt pinning, which
      # causes _all_ packages to be pinned at equal priority
      class { 'apt::backports':
        location => 'http://mirrors.ocf.berkeley.edu/ubuntu/';
      }
    }

    default: {
      warning('Unrecognized operating system; can\'t configure apt!')
    }
  }

  # puppetlabs doesn't currently package for jessie
  if $::lsbdistcodename != 'jessie' {
    apt::key { 'puppetlabs':
      key        => '4BD6EC30',
      key_source => 'https://apt.puppetlabs.com/pubkey.gpg';
    }

    apt::source { 'puppetlabs':
      location   => 'http://apt.puppetlabs.com/',
      repos      => 'main dependencies',
      require    => Apt::Key['puppetlabs'];
    }
  }

  if $desktop {
    apt::key { 'google':
      key        => '7FAC5991',
      key_source => 'https://dl-ssl.google.com/linux/linux_signing_key.pub';
    }

    # mozilla.debian.net doesn't currently package for jessie
    if $::lsbdistcodename != 'jessie' {
      package { 'pkg-mozilla-archive-keyring':; }

      apt::source {
        'mozilla':
          location    => 'http://mozilla.debian.net/',
          release     => "${::lsbdistcodename}-backports",
          repos       => 'iceweasel-release',
          include_src => false,
          require     => Package['pkg-mozilla-archive-keyring'];
      }
    }

    # Chrome creates /etc/apt/sources.list.d/google-chrome.list upon
    # installation, so we use the name 'google-chrome' to avoid duplicates
    #
    # Chrome will overwrite the puppet apt source during install, but puppet
    # will later change it back. They say the same thing so it's cool.
    apt::source {
      'google-chrome':
        location    => 'http://dl.google.com/linux/chrome/deb/',
        release     => 'stable',
        repos       => 'main',
        include_src => false,
        require     => Apt::Key['google'];
    }
  }

  file { '/etc/cron.daily/ocf-apt':
    mode    => '0755',
    content => template('common/apt/ocf-apt.erb'),
    require => Package['aptitude'];
  }
}
