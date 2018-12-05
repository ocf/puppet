class ocf::apt($stage = 'first') {
  package { ['aptitude', 'imvirt', 'apt-transport-https', 'lsb-release']:; }

  class { '::apt':
    # Run apt update at every Puppet run.
    update => {
      frequency => 'always',
      loglevel  => 'debug',
    },

    purge  => {
      'sources.list'   => true,
      'sources.list.d' => true,
      'preferences.d'  => true,
    };
  }

  $repos = 'main contrib non-free'

  if $::lsbdistid == 'Debian' {
    apt::source {
      'debian':
        location => 'http://mirrors/debian/',
        release  => $::lsbdistcodename,
        repos    => $repos,
        include  => {
          src => true
        };

      'debian-updates':
        location => 'http://mirrors/debian/',
        release  => "${::lsbdistcodename}-updates",
        repos    => $repos,
        include  => {
          src => true
        };

      'debian-security':
        location => 'http://mirrors/debian-security/',
        release  => "${::lsbdistcodename}/updates",
        repos    => $repos,
        include  => {
          src => true
        };

      # Debian primary mirror backup, in case ours goes down.
      'debian-backup':
        location => 'ftp://ftp.us.debian.org/debian/',
        release  => $::lsbdistcodename,
        repos    => $repos,
        include  => {
          src => true
        };

      'debian-updates-backup':
        location => 'ftp://ftp.us.debian.org/debian/',
        release  => "${::lsbdistcodename}-updates",
        repos    => $repos,
        include  => {
          src => true
        };

      'debian-security-backup':
        location => 'ftp://ftp.us.debian.org/debian-security/',
        release  => "${::lsbdistcodename}/updates",
        repos    => $repos,
        include  => {
          src => true
        };

      'ocf':
        location => 'http://apt/',
        release  => $::lsbdistcodename,
        repos    => 'main',
        include  => {
          src => true
        };

      'ocf-backports':
        location => 'http://apt/',
        release  => "${::lsbdistcodename}-backports",
        repos    => 'main',
        include  => {
          src => true
        };
    }

    # Pin anything coming from *-backports to be lower than normal priority
    apt::pin { 'ocf-backports':
      priority => 200,
      codename => "${::lsbdistcodename}-backports",
    }

    if $::lsbdistcodename != 'buster' {
      # TODO: Submit patch to puppetlabs-apt to enable having includes for
      # apt::backports (so that we can include the source too)
      class { 'apt::backports':
        location => 'http://mirrors/debian/';
      }
    }

  } elsif $::lsbdistid == 'Raspbian' {
    apt::source {
      'raspbian':
        location => 'http://mirrors/raspbian/raspbian/',
        release  => $::lsbdistcodename,
        repos    => 'main contrib non-free rpi',
        include  => {
          src => true
        };

      'archive-rpi':
        location => 'http://archive.raspberrypi.org/debian/',
        release  => $::lsbdistcodename,
        repos    => 'main ui',
        include  => {
          src => true
        };
    }
  }

  # workaround Debian #793444 by disabling pdiffs
  # https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=793444
  if $::lsbdistcodename == 'jessie' {
    file { '/etc/apt/apt.conf.d/99-workaround-debian-793444':
      content => "Acquire::PDiffs \"false\";\n";
    }
  }

  # TODO: Add the puppetlabs repo to buster when it is available
  if $::lsbdistcodename in ['jessie', 'stretch'] {
    $puppetlabs_repo = $::lsbdistcodename ? {
      'jessie'  => 'PC1',
      'stretch' => 'puppet',
    }

    apt::source {
      'puppetlabs':
        location => 'http://mirrors/puppetlabs/apt/',
        release  => $::lsbdistcodename,
        repos    => $puppetlabs_repo,
    }

    # Add the puppetlabs apt repo key
    apt::key { 'puppet gpg key':
      id     => '6F6B15509CF8E59E6E469F327F438280EF8D349F',
      source => 'https://mirrors.ocf.berkeley.edu/puppetlabs/apt/pubkey.gpg';
    }
  }

  apt::key { 'ocf':
    id     => '9FBEC942CCA7D929B41A90EC45A686E7D72A0AF4',
    source => 'https://apt.ocf.berkeley.edu/pubkey.gpg';
  }

  file { '/etc/cron.daily/ocf-apt':
    mode    => '0755',
    source  => 'puppet:///modules/ocf/apt/ocf-apt',
    require => Package['aptitude'];
  }
}
