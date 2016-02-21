class ocf::apt {
  package { ['aptitude', 'imvirt']:; }

  class { '::apt':
    purge => {
      'sources.list'   => true,
      'sources.list.d' => true,
      'preferences.d'  => true,
    };
  }

  case $::operatingsystem {
    'Debian': {
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
    }

    default: {
      warning('Unrecognized operating system; can\'t configure apt!')
    }
  }

  apt::key { 'ocf':
    id     => '9FBEC942CCA7D929B41A90EC45A686E7D72A0AF4',
    source => 'https://apt.ocf.berkeley.edu/pubkey.gpg';
  }

  if $desktop {
    exec { 'add-i386':
      command => 'dpkg --add-architecture i386',
      unless  => 'dpkg --print-foreign-architectures | grep i386',
      notify => Exec['apt_update'];
    }

    apt::key { 'google':
      id     => '4CCA1EAF950CEE4AB83976DCA040830F7FAC5991',
      source => 'https://dl-ssl.google.com/linux/linux_signing_key.pub';
    }

    # Chrome creates /etc/apt/sources.list.d/google-chrome.list upon
    # installation, so we use the name 'google-chrome' to avoid duplicates
    #
    # Chrome will overwrite the puppet apt source during install, but puppet
    # will later change it back. They say the same thing so it's cool.
    apt::source {
      'google-chrome':
        location    => '[arch=amd64] http://dl.google.com/linux/chrome/deb/',
        release     => 'stable',
        repos       => 'main',
        include   => {
          src => false
        },
        require     => Apt::Key['google'];
    }
  }

  if tagged('ocf_mesos::slave') or tagged('ocf_mesos::master') {
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
  }

  file { '/etc/cron.daily/ocf-apt':
    mode    => '0755',
    content => template('ocf/apt/ocf-apt.erb'),
    require => Package['aptitude'];
  }
}
