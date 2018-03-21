class ocf_hpc::compute {
  require ocf_hpc

  # install proprietary nvidia drivers
  package { ['nvidia-driver', 'nvidia-settings', 'nvidia-cuda-toolkit']:; }

  service { 'slurmd':
    ensure     => 'running',
    enable     => true,
    hasrestart => true,
    subscribe  => File['/etc/slurm-llnl/slurm.conf'],
  }
}
