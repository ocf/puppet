class ocf_hpc::controller {
  require ocf_hpc

  $slurmdbd_mysql_password = lookup('hpc::controller::slurmdbd_mysql_password')

  package { 'slurmdbd': } -> file { '/etc/slurm-llnl/slurmdbd.conf':
    content   => template('ocf_hpc/slurmdbd.conf.erb'),
    mode      => '0600',
    owner     => 'slurm',
    group     => 'slurm',
    show_diff => false,
  } ~> service { 'slurmdbd':
    ensure     => 'running',
    enable     => true,
    hasrestart => true,
  }

  service { 'slurmctld':
    ensure     => 'running',
    enable     => true,
    hasrestart => true,
    subscribe  => [
      File['/etc/slurm-llnl/slurm.conf'],
      File['/etc/slurm-llnl/cgroup.conf']
    ],
  }

  # Set up script to autoadd LDAP group members to SLURM.
  file { '/usr/local/bin/add_slurm_users':
    source => 'puppet:///modules/ocf_hpc/add_slurm_users',
    owner  => 'root',
    mode   => '0755',
  } -> cron { 'add_slurm_users':
    command => '/usr/local/bin/add_slurm_users',
    user    => 'slurm',
    minute  => '*/15',
  }
}
