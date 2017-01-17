class ocf::apt($stage = 'first') {
  package { ['aptitude', 'imvirt']:; }

  class { '::apt':
    purge => {
      'sources.list'   => true,
      'sources.list.d' => true,
      'preferences.d'  => true,
    };
  }

  $repos = 'main contrib non-free'

  # Stretch is somehow classified as sid by Puppet, so this just makes sure
  # that packages are installed from stretch repos instead of from sid ones
  $dist = $::lsbdistcodename ? {
    'jessie'        => 'jessie',
    /(sid|stretch)/ => 'stretch',
  }

  apt::source {
    'debian':
      location  => 'http://mirrors/debian/',
      release   => $dist,
      repos     => $repos,
      include   => {
        src => true
      };

    'debian-security':
      location  => 'http://mirrors/debian-security/',
      release   => "${dist}/updates",
      repos     => $repos,
      include   => {
        src => true
      };

    'ocf':
      location  => 'http://apt/',
      release   => $dist,
      repos     => 'main',
      include   => {
        src => true
      };

    'ocf-backports':
      location  => 'http://apt/',
      release   => "${::lsbdistcodename}-backports",
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
    apt::source {
      'debian-updates':
        location  => 'http://mirrors/debian/',
        release   => "${::lsbdistcodename}-updates",
        repos     => $repos,
        include   => {
          src => true
        };

      'puppetlabs':
        location => 'http://mirrors/puppetlabs/apt/',
        release  => $::lsbdistcodename,
        repos    => 'PC1',
        include  => {
          src => true
        };
    }

    class { 'apt::backports':
      location => 'http://mirrors/debian/';
    }

    # Add the puppetlabs apt repo key
    apt::key { 'puppet gpg key':
      id     => '6F6B15509CF8E59E6E469F327F438280EF8D349F',
      server => 'pgp.mit.edu',
    }
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
