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

  apt::key { 'ocf':
    id     => '9FBEC942CCA7D929B41A90EC45A686E7D72A0AF4',
    source => 'https://apt.ocf.berkeley.edu/pubkey.gpg';
  }

  apt::key { 'mesosphere':
    id     => '81026D0004C44CF7EF55ADF8DF7D54CBE56151BF',
    server => 'keyserver.ubuntu.com',
  }

  apt::source { 'mesosphere':
    location => 'http://repos.mesosphere.io/debian/',
    release  => $::lsbdistcodename,
    repos    => 'main',
    require  => Apt::Key['mesosphere'],
  }

  apt::key { 'docker':
    id     => '58118E89F3A912897C070ADBF76221572C52609D',
    server => 'keyserver.ubuntu.com',
  }

  apt::source { 'docker':
    location    => 'http://apt.dockerproject.org/repo',
    release     => 'debian-jessie',
    repos       => 'main',
    include   => {
      src => false
    },
    require     => Apt::Key['docker'];
  }

  file { '/etc/cron.daily/ocf-apt':
    mode    => '0755',
    content => template('ocf/apt/ocf-apt.erb'),
    require => Package['aptitude'];
  }
}
