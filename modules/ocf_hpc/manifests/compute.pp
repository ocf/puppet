class ocf_hpc::compute {
  require ocf_hpc

  # install proprietary nvidia drivers
  package { ['nvidia-driver', 'nvidia-settings', 'nvidia-cuda-toolkit']:; }

  file { '/etc/slurm-llnl/gres.conf':
    content => template('ocf_hpc/gres.conf.erb'),
    mode    => '0644',
    owner   => 'slurm',
    group   => 'slurm',
  }
  # Kernel option to enable memory as a consumable gres resource
  augeas { 'grub':
    incl    => '/etc/default/grub',
    lens    => 'ShellVars.lns',
    changes => [
      "set GRUB_CMDLINE_LINUX '\"cgroup_enable=memory swapaccount=1\"'",
    ],
  } ~> exec { 'update-grub':
    user        => 'root',
    refreshonly => true,
  }

  service { 'slurmd':
    ensure     => 'running',
    enable     => true,
    hasrestart => true,
    subscribe  => [
      File['/etc/slurm-llnl/slurm.conf'],
      File['/etc/slurm-llnl/gres.conf'],
      File['/etc/slurm-llnl/cgroup.conf'],
    ],
  }
}
