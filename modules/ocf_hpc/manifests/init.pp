class ocf_hpc {
  include ocf::ipmi

  package { 'singularity-container':
    install_options => ['-t stretch-backports'],
  }

  package { 'slurm-wlm':
  } -> file { '/etc/slurm-llnl/slurm.conf':
    source  => 'puppet:///modules/ocf_hpc/files/slurm.conf',
    mode    => '0644',
    owner   => 'slurm',
    group   => 'slurm',
  }
  if $::puppetdb_running {
    $slurm_nodes_facts_query = 'inventory[facts] { resources { type = "Class" and title = "Ocf_hpc::compute" } }'
    $slurm_nodes_facts = puppetdb_query($::slurm_nodes_query).map |$value| { $value['facts'] }
  }
  else {
    file { '/etc/slurm-llnl/slurm.conf':
      ensure => 'present',
    }
  }
}
