class ocf_hpc::singularity {

  ocf::repackage { 'singularity-container':
    backport_on => ['buster'],
  }

  file { '/etc/singularity/singularity.conf':
    source => 'puppet:///modules/ocf_hpc/singularity.conf',
  }

  # Each running singularity container consumes a loop device,
  # and the default max loop devices is 8.
  # Requires reboot after change.
  augeas { 'Set max loop devices for Singularity':
    incl    => '/etc/modules',
    lens    => 'Modules.lns',
    changes => ['set loop max_loop=256'],
  }
}
