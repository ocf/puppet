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

  if $::os['distro']['id'] == 'Debian' {
      if $::operatingsystemmajrelease != '11' {
        apt::source {
        'debian':
            location => 'http://mirrors/debian/',
            release  => $::os['distro']['codename'],
            repos    => $repos,
            include  => {
            src => true
            };

        'debian-updates':
            location => 'http://mirrors/debian/',
            release  => "${::os['distro']['codename']}-updates",
            repos    => $repos,
            include  => {
            src => true
            };

        'debian-security':
            location => 'http://mirrors/debian-security/',
            release  => "${::os['distro']['codename']}/updates",
            repos    => $repos,
            include  => {
            src => true
            };

        'ocf':
            location => 'http://apt/',
            release  => $::os['distro']['codename'],
            repos    => 'main',
            include  => {
            src => true
            };

        'ocf-backports':
            location => 'http://apt/',
            release  => "${::os['distro']['codename']}-backports",
            repos    => 'main',
            include  => {
            src => true
            };
        }

        # Pin anything coming from *-backports to be lower than normal priority
        apt::pin { 'ocf-backports':
        priority => 200,
        codename => "${::os['distro']['codename']}-backports",
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
            release  => $::os['distro']['codename'],
            repos    => $repos,
            include  => {
            src => true
            };

        'debian-updates':
            location => 'http://mirrors/debian/',
            release  => "${::os['distro']['codename']}-updates",
            repos    => $repos,
            include  => {
            src => true
            };

        'debian-security':
            location => 'http://mirrors/debian-security/',
            release  => "${::os['distro']['codename']}-security",
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
        codename => "${::os['distro']['codename']}-backports",
        }

        # TODO: Submit patch to puppetlabs-apt to enable having includes for
        # apt::backports (so that we can include the source too)
        class { 'apt::backports':
        location => 'http://mirrors/debian/';
        }
}

  } elsif $::os['distro']['id'] == 'Raspbian' {
    apt::source {
      'raspbian':
        location => 'http://mirrors/raspbian/raspbian/',
        release  => $::os['distro']['codename'],
        repos    => 'main contrib non-free rpi',
        include  => {
          src => true
        };

      'archive-rpi':
        location => 'http://archive.raspberrypi.org/debian/',
        release  => $::os['distro']['codename'],
        repos    => 'main ui',
        include  => {
          src => true
        };
    }
  }

  apt::source {
    'puppetlabs':
      location => 'http://mirrors/puppetlabs/apt/',
      release  => $::os['distro']['codename'],
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
