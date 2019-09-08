class ocf_decal {
  include apache
  include ocf_decal::website

  user { 'ocfdecal':
    comment => 'DeCal management account',
    home    => '/opt/ocfdecal',
    shell   => '/bin/bash',
    groups  => 'www-data',
  }

  file {
    '/opt/ocfdecal':
      ensure  => directory,
      owner   => ocfdecal,
      group   => ocfdecal,
      require => User['ocfdecal'];
  }

  ocf::privatefile { '/etc/decal_mysql.conf':
    source  => 'puppet:///private/mysql.conf',
    owner   => ocfdecal,
    group   => ocfstaff,
    mode    => '0440',
    require => User['ocfdecal'];
  }

  vcsrepo { '/opt/share/decal-utils':
    ensure   => latest,
    provider => git,
    revision => 'master',
    source   => 'https://github.com/0xcf/decal-utils.git'
  }
}
