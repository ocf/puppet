class ocf_mesos::package::apt {
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
