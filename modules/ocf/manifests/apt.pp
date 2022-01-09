class ocf::apt($stage = 'first') {
  package { ['aptitude', 'imvirt', 'apt-transport-https', 'lsb-release', 'ethtool', 'unattended-upgrades']:; }

  class { '::apt':
    purge => {
      'sources.list'   => true,
      'sources.list.d' => true,
      'preferences.d'  => true,
    };
  }

  $repos = 'main contrib non-free'

  if $::lsbdistid == 'Debian' {
      if $::operatingsystemmajrelease == '12' {
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
            release  => "${::lsbdistcodename}-security",
            repos    => $repos,
            include  => {
            src => true
            };

        'ocf':
            location => 'http://apt/',
            release  => 'buster',
            repos    => 'main',
            include  => {
            src => true
            };

        'ocf-backports':
            location => 'http://apt/',
            release  => 'buster-backports',
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

        # TODO: Submit patch to puppetlabs-apt to enable having includes for
        # apt::backports (so that we can include the source too)
        class { 'apt::backports':
        location => 'http://mirrors/debian/';
        }
    }
    elsif $::operatingsystemmajrelease != '11' {
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

        # TODO: Submit patch to puppetlabs-apt to enable having includes for
        # apt::backports (so that we can include the source too)
        class { 'apt::backports':
        location => 'http://mirrors/debian/';
        }

    }
else {
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
            release  => "${::lsbdistcodename}-security",
            repos    => $repos,
            include  => {
            src => true
            };

        'ocf':
            location => 'http://apt/',
            release  => 'buster',
            repos    => 'main',
            include  => {
            src => true
            };

        'ocf-backports':
            location => 'http://apt/',
            release  => 'buster-backports',
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

  apt::source {
    'puppetlabs':
      location => 'http://mirrors/puppetlabs/apt/',
      release  => $::lsbdistcodename,
      repos    => 'puppet',
  }

  # Add the puppetlabs apt repo key
  apt::key { 'puppet gpg key':
    id     => 'D6811ED3ADEEB8441AF5AA8F4528B6CD9E61EF26',
    source => 'https://mirrors.ocf.berkeley.edu/puppetlabs/apt/pubkey.gpg';
  }

  apt::key { 'ocf':
    id     => '9FBEC942CCA7D929B41A90EC45A686E7D72A0AF4',
    source => 'https://apt.ocf.berkeley.edu/pubkey.gpg';
  }

  # Configure automatic security upgrades
  file {
    '/etc/apt/apt.conf.d/50unattended-upgrades':
      source  => 'puppet:///modules/ocf/apt/50unattended-upgrades';

    '/etc/apt/apt.conf.d/02periodic':
      source  => 'puppet:///modules/ocf/apt/02periodic';
  }
}
