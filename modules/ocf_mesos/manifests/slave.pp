class ocf_mesos::slave {
  include ocf::packages::docker
  include ocf_mesos
  include ocf_mesos::package
  include ocf_mesos::slave::secrets

  augeas { '/etc/default/mesos-slave':
    lens    => 'Shellvars.lns',
    incl    => '/etc/default/mesos-slave',
    changes =>  [
      'set MASTER "zk://mesos0:2181,mesos1:2181,mesos2:2181/mesos"',
    ],
    notify  => Service['mesos-slave'],
    require => Package['mesos'];
  }

  $ocf_mesos_password = 'hunter2'

  # TODO: when on Puppet 4, use per-expression defaults
  # https://docs.puppet.com/puppet/latest/reference/lang_resources_advanced.html#local-resource-defaults
  file {
    '/opt/share/mesos/slave':
      ensure => directory,
      notify  => Service['mesos-slave'],
      require => Package['mesos'];

    '/etc/mesos-slave':
      ensure  => directory,
      recurse => true,
      purge   => true,
      notify  => Service['mesos-slave'],
      require => Package['mesos'];

    '/etc/mesos-slave/containerizers':
      content => "docker\n",
      notify  => Service['mesos-slave'],
      require => Package['mesos'];

    # increase executor timeout in case we need to pull a Docker image
    '/etc/mesos-slave/executor_registration_timeout':
      content => "5mins\n",
      notify  => Service['mesos-slave'],
      require => Package['mesos'];

    # remove old dockers as soon as we're done with them
    '/etc/mesos-slave/docker_remove_delay':
      content => "1secs\n",
      notify  => Service['mesos-slave'],
      require => Package['mesos'];

    '/etc/mesos-slave/hostname':
      content => "${::hostname}\n",
      notify  => Service['mesos-slave'],
      require => Package['mesos'];


    '/etc/mesos-slave/credential':
      content => "/opt/share/mesos/slave/credential.json\n",
      require => [Package['mesos'], File['/opt/share/mesos/slave/credential.json']],
      notify  => Service['mesos-slave'];

    '/opt/share/mesos/slave/credential.json':
      content   => template('ocf_mesos/slave/mesos/credential.json.erb'),
      mode      => '0400',
      show_diff => false,
      notify  => Service['mesos-slave'],
      require => Package['mesos'];
  }
}
