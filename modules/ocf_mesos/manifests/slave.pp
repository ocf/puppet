class ocf_mesos::slave($attributes = {}) {
  include ocf::packages::docker
  include ocf_mesos
  include ocf_mesos::package

  $masters = hiera('mesos_masters')

  # TODO: can we not duplicate this between slave/master?
  # looks like: mesos0:2181,mesos1:2181,mesos2:2181
  $zookeeper_host = join(keys($masters).map |$m| { "${m}:2181" }, ',')

  augeas { '/etc/default/mesos-slave':
    lens    => 'Shellvars.lns',
    incl    => '/etc/default/mesos-slave',
    changes =>  [
      "set MASTER 'zk://${zookeeper_host}/mesos'",
    ],
    notify  => Service['mesos-slave'],
    require => Package['mesos'];
  }


  $ocf_mesos_master_password = file('/opt/puppet/shares/private/mesos/mesos-master-password')
  $ocf_mesos_slave_password = file('/opt/puppet/shares/private/mesos/mesos-slave-password')

  file {
    default:
      notify  => Service['mesos-slave'],
      require => Package['mesos'];

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

    # Credentials needed to access the slave REST API.
    [
      '/etc/mesos-slave/authenticate_http_readonly',
      '/etc/mesos-slave/authenticate_http_readwrite',
    ]:
      content => "true\n";

    '/etc/mesos-slave/work_dir':
      content => "/var/lib/mesos-slave\n",
      require => File['/var/lib/mesos-slave'];

    '/var/lib/mesos-slave':
      ensure => directory;

    '/etc/mesos-slave/http_credentials':
      content => "/opt/share/mesos/slave/slave_credentials.json\n",
      require => File['/opt/share/mesos/slave/slave_credentials.json'];

    '/opt/share/mesos/slave/slave_credentials.json':
      content   => template('ocf_mesos/slave/mesos/slave_credentials.json.erb'),
      mode      => '0400',
      show_diff => false;

    # Credential to connect to the masters.
    '/etc/mesos-slave/credential':
      content => "/opt/share/mesos/slave/master_credential.json\n",
      require => File['/opt/share/mesos/slave/master_credential.json'];

    '/opt/share/mesos/slave/master_credential.json':
      content   => template('ocf_mesos/slave/mesos/master_credential.json.erb'),
      mode      => '0400',
      show_diff => false;
  }

  concat { '/etc/mesos-slave/attributes':
    ensure         => present,
    ensure_newline => true,
    force          => true, # TODO: Remove once upgraded to concat 2.x
    notify         => Exec['reset-agent'],
  }

  # Provide a custom start script which enables wiping the agent settings.
  file { '/usr/local/bin/ocf-mesos-slave':
    source => 'puppet:///modules/ocf_mesos/slave/ocf-mesos-slave',
    mode   => '0755',
  }

  ocf::systemd::override { 'mesos-slave-change-start':
    unit    => 'mesos-slave.service',
    content => "[Service]\nExecStart=\nExecStart=/usr/local/bin/ocf-mesos-slave\n",
    require => File['/usr/local/bin/ocf-mesos-slave'],
  }

  # Some operations change the agent's "info" and require the entire agent to
  # be reset. These notify this exec.
  exec { 'reset-agent':
    command     => 'touch /var/lib/mesos-slave/reset-needed',
    refreshonly => true,
    notify      => Service['mesos-slave'],
  }

  # Custom attributes
  create_resources(ocf_mesos::slave::attribute, $attributes)
}
