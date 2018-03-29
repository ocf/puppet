class ocf_hpc::controller {
  require ocf_hpc

  $slurmdbd_mysql_password = hiera('hpc::controller::slurmdbd_mysql_password')

  package { 'slurmdbd':
  } -> file { '/etc/slurm-llnl/slurmdbd.conf':
    source  => 'puppet:///modules/ocf_hpc/slurmdbd.conf',
    mode    => '0600',
    owner   => 'slurm',
    group   => 'slurm',
  } -> augeas { 'slurmdbd.conf':
    incl    => '/etc/slurm-llnl/slurmdbd.conf',
    lens    => 'Simplevars.lns',
    changes => [
      "set StoragePass ${slurmdbd_mysql_password}",
      "set DbdHost ${::hostname}",
    ],
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
