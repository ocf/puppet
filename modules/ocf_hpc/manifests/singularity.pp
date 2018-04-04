class ocf_hpc::singularity {

  package { 'singularity-container':
    install_options => ['-t stretch-backports'],
  }

  file { '/etc/singularity/singularity.conf':
    source => 'puppet:///modules/ocf_hpc/singularity.conf',
    mode   => '0644',
    owner  => 'root',
    group  => 'root',
  }

  # Each running singularity container consumes a loop device,
  # and the default max loop devices is 8.
  # Requires reboot after change.
  augeas { 'modules':
    incl    => '/etc/modules',
    lens    => 'Modules.lns',
    changes => ['set loop max_loop=256'],
  }
}
