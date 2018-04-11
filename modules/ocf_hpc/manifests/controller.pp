class ocf_hpc::controller {
  require ocf_hpc

  $slurmdbd_mysql_password = hiera('hpc::controller::slurmdbd_mysql_password')

  package { 'slurmdbd':
  } -> file { '/etc/slurm-llnl/slurmdbd.conf':
    content => template('ocf_hpc/slurmdbd.conf.erb'),
    mode    => '0600',
    owner   => 'slurm',
    group   => 'slurm',
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
}
