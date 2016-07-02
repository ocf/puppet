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

  File {
    notify  => Service['mesos-slave'],
    require => Package['mesos'],
  }

  $ocf_mesos_password = 'hunter2'

  file {
    '/opt/share/mesos/slave':
      ensure => directory;

    '/etc/mesos-slave':
      ensure  => directory,
      recurse => true,
      purge   => true;

    '/etc/mesos-slave/containerizers':
      content => "docker\n";

    # increase executor timeout in case we need to pull a Docker image
    '/etc/mesos-slave/executor_registration_timeout':
      content => "5mins\n";

    # remove old dockers as soon as we're done with them
    '/etc/mesos-slave/docker_remove_delay':
      content => "1secs\n";

    '/etc/mesos-slave/hostname':
      content => "${::hostname}\n";


    '/etc/mesos-slave/credential':
      content => "/opt/share/mesos/slave/credential.json\n",
      require => File['/opt/share/mesos/slave/credential.json'];

    '/opt/share/mesos/slave/credential.json':
      content   => template('ocf_mesos/slave/mesos/credential.json.erb'),
      mode      => '0400',
      show_diff => false;

  }
}
