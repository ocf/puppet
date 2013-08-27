class maelstrom {

  # install mysql and set root password
  package { 'mysql-server-5.1':
    responsefile => '/opt/share/puppet/mysql-server-5.1.preseed'
  }
  file { '/opt/share/puppet/mysql-server-5.1.preseed':
    mode         => '0600',
    source       => 'puppet:///private/mysql-server-5.1.preseed'
  }

  # provide mysql server and client config
  file {
    '/etc/mysql/my.cnf':
      source => 'puppet:///modules/maelstrom/my.cnf';
    '/root/.my.cnf':
      mode   => '0600',
      source => 'puppet:///private/root-my.cnf'
  }

  service { 'mysql':
    subscribe => File['/etc/mysql/my.cnf'],
    require   => Package['mysql-server-5.1']
  }

  # add percona repo
  file { '/etc/apt/sources.list.d/percona.list':
    content => "deb http://repo.percona.com/apt ${::lsbdistcodename} main",
    before  => Exec['percona'],
  }

  # trust percona key
  exec { 'percona':
    command => 'apt-key adv --keyserver keys.gnupg.net --recv-keys 1C4CBDCDCD2EFD2A',
    unless  => 'apt-key list | grep CD2EFD2A',
    before  => Exec['force aptitude update'],
    require => File['/etc/apt/sources.list.d/percona.list'],
  }

  # local copy to avoid dependency cycles
  exec { 'force aptitude update':
    command     => 'aptitude update',
    refreshonly => true,
    require     => Package['aptitude'],
  }

}
