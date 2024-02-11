class ocf::apt($stage = 'first') {
  package { ['aptitude', 'imvirt', 'lsb-release', 'ethtool', 'unattended-upgrades']:; }

  class { '::apt':
    purge => {
      'sources.list'   => true,
      'sources.list.d' => true,
      'preferences.d'  => true,
    };
  }
  if $facts['os']['release']['major'] == '12' {
    $repos = 'main contrib non-free non-free-firmware'
  } else {
    $repos = 'main contrib non-free'
  }

  if $facts['os']['distro']['id'] == 'Debian' {
    if $facts['os']['release']['major'] == '9' {
      apt::key { 'freexian':
          id     => 'AB597C4F6F3380BD4B2BEBC2A07310D369055D5A',
          source => 'https://deb.freexian.com/extended-lts/archive-key.gpg';
          }

      apt::source {
      'debian':
          location => 'https://mirrors.wikimedia.org/debian/',
          release  => $facts['os']['distro']['codename'],
          repos    => $repos,
          include  => {
          src => true
          };

      'debian-updates':
          location => 'https://mirrors.wikimedia.org/debian/',
          release  => "${facts['os']['distro']['codename']}-updates",
          repos    => $repos,
          include  => {
          src => true
          };

      'debian-security':
          location => 'http://deb.debian.org/debian-security/',
          release  => "${facts['os']['distro']['codename']}/updates",
          repos    => $repos,
          include  => {
          src => true
          };

      'extended-lts':
          location => 'http://deb.freexian.com/extended-lts/',
          release  => $facts['os']['distro']['codename'],
          repos    => $repos;

      }

      # Pin anything coming from *-backports to be lower than normal priority
      apt::pin { 'ocf-backports':
      priority => 200,
      codename => "${facts['os']['distro']['codename']}-backports",
      }

      # TODO: Submit patch to puppetlabs-apt to enable having includes for
      # apt::backports (so that we can include the source too)
      class { 'apt::backports':
      location => 'https://mirrors.wikimedia.org/debian/';
      }
    }
  elsif $facts['os']['release']['major'] == '10' {
    apt::source {
      'debian':
          location => 'https://mirrors.wikimedia.org/debian/',
          release  => $facts['os']['distro']['codename'],
          repos    => $repos,
          include  => {
          src => true
          };

      'debian-updates':
          location => 'https://mirrors.wikimedia.org/debian/',
          release  => "${facts['os']['distro']['codename']}-updates",
          repos    => $repos,
          include  => {
          src => true
          };

      'debian-security':
          location => 'http://deb.debian.org/debian-security/',
          release  => "${facts['os']['distro']['codename']}/updates",
          repos    => $repos,
          include  => {
          src => true
          };

      }

      # Pin anything coming from *-backports to be lower than normal priority
      apt::pin { 'ocf-backports':
      priority => 200,
      codename => "${facts['os']['distro']['codename']}-backports",
      }

      # TODO: Submit patch to puppetlabs-apt to enable having includes for
      # apt::backports (so that we can include the source too)
      class { 'apt::backports':
      location => 'https://mirrors.wikimedia.org/debian/';
      }

    }
  else {
    apt::source {
      'debian':
          location => 'https://mirrors.wikimedia.org/debian/',
          release  => $facts['os']['distro']['codename'],
          repos    => $repos,
          include  => {
          src => true
          };

      'debian-updates':
          location => 'https://mirrors.wikimedia.org/debian/',
          release  => "${facts['os']['distro']['codename']}-updates",
          repos    => $repos,
          include  => {
          src => true
          };

      'debian-security':
          location => 'http://deb.debian.org/debian-security/',
          release  => "${facts['os']['distro']['codename']}-security",
          repos    => $repos,
          include  => {
          src => true
          };

      }

      # Pin anything coming from *-backports to be lower than normal priority
      apt::pin { 'ocf-backports':
      priority => 200,
      codename => "${facts['os']['distro']['codename']}-backports",
      }

      # TODO: Submit patch to puppetlabs-apt to enable having includes for
      # apt::backports (so that we can include the source too)
      class { 'apt::backports':
      location => 'https://mirrors.wikimedia.org/debian/';
      }
  }

  } elsif $facts['os']['distro']['id'] == 'Raspbian' {
    apt::source {
      'raspbian':
        location => 'https://mirrors.ocf.berkeley.edu/raspbian/raspbian/',
        release  => $facts['os']['distro']['codename'],
        repos    => 'main contrib non-free rpi',
        include  => {
          src => true
        };

      'archive-rpi':
        location => 'https://archive.raspberrypi.org/debian/',
        release  => $facts['os']['distro']['codename'],
        repos    => 'main ui',
        include  => {
          src => true
        };
    }
  }
  if $facts['os']['release']['major'] == '12' {
    apt::source {
      'puppetlabs':
        location => 'https://apt.puppetlabs.com/',
        release  => 'bullseye',
        repos    => 'puppet',
    }
  } else {
    apt::source {
      'puppetlabs':
        location => 'https://apt.puppetlabs.com/',
        release  => $facts['os']['distro']['codename'],
        repos    => 'puppet',
    }
  }

  # Add the puppetlabs apt repo key
  apt::key { 'puppet gpg key':
    id     => 'D6811ED3ADEEB8441AF5AA8F4528B6CD9E61EF26',
    source => 'https://mirrors.ocf.berkeley.edu/puppetlabs/apt/pubkey.gpg';
  }


  # Configure automatic security upgrades
  file {
    '/etc/apt/apt.conf.d/50unattended-upgrades':
      source  => 'puppet:///modules/ocf/apt/50unattended-upgrades';

    '/etc/apt/apt.conf.d/02periodic':
      source  => 'puppet:///modules/ocf/apt/02periodic';
  }
}
