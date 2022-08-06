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
      if $::operatingsystemmajrelease == '9' {
        apt::key { 'freexian':
            id     => 'AB597C4F6F3380BD4B2BEBC2A07310D369055D5A',
            source => 'https://deb.freexian.com/extended-lts/archive-key.gpg';
            }

        apt::source {
        'debian':
            location => 'https://mirrors.ocf.berkeley.edu/debian/',
            release  => $::lsbdistcodename,
            repos    => $repos,
            include  => {
            src => true
            };

        'debian-updates':
            location => 'https://mirrors.ocf.berkeley.edu/debian/',
            release  => "${::lsbdistcodename}-updates",
            repos    => $repos,
            include  => {
            src => true
            };

        'debian-security':
            location => 'https://mirrors.ocf.berkeley.edu/debian-security/',
            release  => "${::lsbdistcodename}/updates",
            repos    => $repos,
            include  => {
            src => true
            };

        'extended-lts':
            location => 'http://deb.freexian.com/extended-lts',
            release  => $::lsbdistcodename,
            repos    => $repos;

        'ocf':
            location => 'https://apt.ocf.berkeley.edu/',
            release  => $::lsbdistcodename,
            repos    => 'main',
            include  => {
            src => true
            };

        'ocf-backports':
            location => 'https://apt.ocf.berkeley.edu/',
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
        location => 'https://mirrors.ocf.berkeley.edu/debian/';
        }

    }
     else if $::operatingsystemmajrelease == '10' {
        apt::source {
        'debian':
            location => 'https://mirrors.ocf.berkeley.edu/debian/',
            release  => $::lsbdistcodename,
            repos    => $repos,
            include  => {
            src => true
            };

        'debian-updates':
            location => 'https://mirrors.ocf.berkeley.edu/debian/',
            release  => "${::lsbdistcodename}-updates",
            repos    => $repos,
            include  => {
            src => true
            };

        'debian-security':
            location => 'https://mirrors.ocf.berkeley.edu/debian-security/',
            release  => "${::lsbdistcodename}/updates",
            repos    => $repos,
            include  => {
            src => true
            };

        'ocf':
            location => 'https://apt.ocf.berkeley.edu/',
            release  => $::lsbdistcodename,
            repos    => 'main',
            include  => {
            src => true
            };

        'ocf-backports':
            location => 'https://apt.ocf.berkeley.edu/',
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
        location => 'https://mirrors.ocf.berkeley.edu/debian/';
        }

    }
else {
    apt::source {
        'debian':
            location => 'https://mirrors.ocf.berkeley.edu/debian/',
            release  => $::lsbdistcodename,
            repos    => $repos,
            include  => {
            src => true
            };

        'debian-updates':
            location => 'https://mirrors.ocf.berkeley.edu/debian/',
            release  => "${::lsbdistcodename}-updates",
            repos    => $repos,
            include  => {
            src => true
            };

        'debian-security':
            location => 'https://mirrors.ocf.berkeley.edu/debian-security/',
            release  => "${::lsbdistcodename}-security",
            repos    => $repos,
            include  => {
            src => true
            };

        'ocf':
            location => 'https://apt.ocf.berkeley.edu/',
            release  => $::lsbdistcodename,
            repos    => 'main',
            include  => {
            src => true
            };

        'ocf-backports':
            location => 'https://apt.ocf.berkeley.edu/',
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
        location => 'https://mirrors.ocf.berkeley.edu/debian/';
        }
}

  } elsif $::lsbdistid == 'Raspbian' {
    apt::source {
      'raspbian':
        location => 'https://mirrors.ocf.berkeley.edu/raspbian/raspbian/',
        release  => $::lsbdistcodename,
        repos    => 'main contrib non-free rpi',
        include  => {
          src => true
        };

      'archive-rpi':
        location => 'https://archive.raspberrypi.org/debian/',
        release  => $::lsbdistcodename,
        repos    => 'main ui',
        include  => {
          src => true
        };
    }
  }

  apt::source {
    'puppetlabs':
      location => 'https://mirrors.ocf.berkeley.edu/puppetlabs/apt/',
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
