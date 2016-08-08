class ocf::apt {
  package { ['aptitude', 'imvirt']:; }

  class { '::apt':
    purge => {
      'sources.list'   => true,
      'sources.list.d' => true,
      'preferences.d'  => true,
    };
  }

  $repos = 'main contrib non-free'

  apt::source {
    'debian':
      location  => 'http://mirrors/debian/',
      release   => $::lsbdistcodename,
      repos     => $repos,
      include   => {
        src => true
      };

    'debian-security':
      location  => 'http://mirrors/debian-security/',
      release   => "${::lsbdistcodename}/updates",
      repos     => $repos,
      include   => {
        src => true
      };

    'ocf':
      location  => 'http://apt/',
      release   => $::lsbdistcodename,
      repos     => 'main',
      include   => {
        src => true
      };
  }

  # workaround Debian #793444 by disabling pdiffs
  # https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=793444
  if $::lsbdistcodename == 'jessie' {
    file { '/etc/apt/apt.conf.d/99-workaround-debian-793444':
      content => "Acquire::PDiffs \"false\";\n";
    }
  }

  # repos available only for stable
  if $::lsbdistcodename in ['jessie'] {
    apt::source { 'debian-updates':
      location  => 'http://mirrors/debian/',
      release   => "${::lsbdistcodename}-updates",
      repos     => $repos,
      include   => {
        src => true
      };
    }

    class { 'apt::backports':
      location => 'http://mirrors/debian/';
    }
  }

  apt::key { 'puppetlabs':
    id     => '47B320EB4C7C375AA9DAE1A01054B7A24BD6EC30',
    source => 'https://apt.puppetlabs.com/pubkey.gpg';
  }

  # Hack to update the puppetlabs APT signing key with the same signature
  # See https://tickets.puppetlabs.com/browse/MODULES-3307 for more info
  exec { 'apt-key puppetlabs':
    path    => '/bin:/usr/bin',
    unless  => 'apt-key list | grep 4BD6EC30 | grep -v expired',
    command => 'apt-key adv --keyserver keys.gnupg.net --recv-keys 1054b7a24bd6ec30';
  }

  apt::source { 'puppetlabs':
    location   => 'http://apt.puppetlabs.com/',
    repos      => 'PC1',
    require    => Apt::Key['puppetlabs'];
  }

  apt::key { 'ocf':
    id     => '9FBEC942CCA7D929B41A90EC45A686E7D72A0AF4',
    source => 'https://apt.ocf.berkeley.edu/pubkey.gpg';
  }

  file { '/etc/cron.daily/ocf-apt':
    mode    => '0755',
    content => template('ocf/apt/ocf-apt.erb'),
    require => Package['aptitude'];
  }
}
