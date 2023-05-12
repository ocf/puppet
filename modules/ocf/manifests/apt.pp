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

  if $facts['facts['os']['distro']['id']'] == 'Debian' {
    if $facts['facts['os']['release']['major']'] == '9' {
      apt::key { 'freexian':
          id     => 'AB597C4F6F3380BD4B2BEBC2A07310D369055D5A',
          source => 'https://deb.freexian.com/extended-lts/archive-key.gpg';
          }

      apt::source {
      'debian':
          location => 'https://mirrors.ocf.berkeley.edu/debian/',
          release  => $facts['facts['os']['distro']['codename']'],
          repos    => $repos,
          include  => {
          src => true
          };

      'debian-updates':
          location => 'https://mirrors.ocf.berkeley.edu/debian/',
          release  => "${facts['facts['os']['distro']['codename']']}-updates",
          repos    => $repos,
          include  => {
          src => true
          };

      'debian-security':
          location => 'https://mirrors.ocf.berkeley.edu/debian-security/',
          release  => "${facts['facts['os']['distro']['codename']']}/updates",
          repos    => $repos,
          include  => {
          src => true
          };

      'extended-lts':
          location => 'https://mirrors.ocf.berkeley.edu/freexian/',
          release  => $facts['facts['os']['distro']['codename']'],
          repos    => $repos;

      'ocf':
          location => 'https://apt.ocf.berkeley.edu/',
          release  => $facts['facts['os']['distro']['codename']'],
          repos    => 'main',
          include  => {
          src => true
          };

      'ocf-backports':
          location => 'https://apt.ocf.berkeley.edu/',
          release  => "${facts['facts['os']['distro']['codename']']}-backports",
          repos    => 'main',
          include  => {
          src => true
          };
      }

      # Pin anything coming from *-backports to be lower than normal priority
      apt::pin { 'ocf-backports':
      priority => 200,
      codename => "${facts['facts['os']['distro']['codename']']}-backports",
      }

      # TODO: Submit patch to puppetlabs-apt to enable having includes for
      # apt::backports (so that we can include the source too)
      class { 'apt::backports':
      location => 'https://mirrors.ocf.berkeley.edu/debian/';
      }
    }
  elsif $facts['facts['os']['release']['major']'] == '10' {
    apt::source {
      'debian':
          location => 'https://mirrors.ocf.berkeley.edu/debian/',
          release  => $facts['facts['os']['distro']['codename']'],
          repos    => $repos,
          include  => {
          src => true
          };

      'debian-updates':
          location => 'https://mirrors.ocf.berkeley.edu/debian/',
          release  => "${facts['facts['os']['distro']['codename']']}-updates",
          repos    => $repos,
          include  => {
          src => true
          };

      'debian-security':
          location => 'https://mirrors.ocf.berkeley.edu/debian-security/',
          release  => "${facts['facts['os']['distro']['codename']']}/updates",
          repos    => $repos,
          include  => {
          src => true
          };

      'ocf':
          location => 'https://apt.ocf.berkeley.edu/',
          release  => $facts['facts['os']['distro']['codename']'],
          repos    => 'main',
          include  => {
          src => true
          };

      'ocf-backports':
          location => 'https://apt.ocf.berkeley.edu/',
          release  => "${facts['facts['os']['distro']['codename']']}-backports",
          repos    => 'main',
          include  => {
          src => true
          };
      }

      # Pin anything coming from *-backports to be lower than normal priority
      apt::pin { 'ocf-backports':
      priority => 200,
      codename => "${facts['facts['os']['distro']['codename']']}-backports",
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
          release  => $facts['facts['os']['distro']['codename']'],
          repos    => $repos,
          include  => {
          src => true
          };

      'debian-updates':
          location => 'https://mirrors.ocf.berkeley.edu/debian/',
          release  => "${facts['facts['os']['distro']['codename']']}-updates",
          repos    => $repos,
          include  => {
          src => true
          };

      'debian-security':
          location => 'https://mirrors.ocf.berkeley.edu/debian-security/',
          release  => "${facts['facts['os']['distro']['codename']']}-security",
          repos    => $repos,
          include  => {
          src => true
          };

      'ocf':
          location => 'https://apt.ocf.berkeley.edu/',
          release  => $facts['facts['os']['distro']['codename']'],
          repos    => 'main',
          include  => {
          src => true
          };

      'ocf-backports':
          location => 'https://apt.ocf.berkeley.edu/',
          release  => "${facts['facts['os']['distro']['codename']']}-backports",
          repos    => 'main',
          include  => {
          src => true
          };
      }

      # Pin anything coming from *-backports to be lower than normal priority
      apt::pin { 'ocf-backports':
      priority => 200,
      codename => "${facts['facts['os']['distro']['codename']']}-backports",
      }

      # TODO: Submit patch to puppetlabs-apt to enable having includes for
      # apt::backports (so that we can include the source too)
      class { 'apt::backports':
      location => 'https://mirrors.ocf.berkeley.edu/debian/';
      }
  }

  } elsif $facts['facts['os']['distro']['id']'] == 'Raspbian' {
    apt::source {
      'raspbian':
        location => 'https://mirrors.ocf.berkeley.edu/raspbian/raspbian/',
        release  => $facts['facts['os']['distro']['codename']'],
        repos    => 'main contrib non-free rpi',
        include  => {
          src => true
        };

      'archive-rpi':
        location => 'https://archive.raspberrypi.org/debian/',
        release  => $facts['facts['os']['distro']['codename']'],
        repos    => 'main ui',
        include  => {
          src => true
        };
    }
  }

  apt::source {
    'puppetlabs':
      location => 'https://mirrors.ocf.berkeley.edu/puppetlabs/apt/',
      release  => $facts['facts['os']['distro']['codename']'],
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
