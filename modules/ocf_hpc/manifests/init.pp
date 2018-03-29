class ocf_hpc {
  include ocf::ipmi

  package { 'singularity-container':
    install_options => ['-t stretch-backports'],
  }

  package { 'slurm-wlm': }

  if $::puppetdb_running {
    $slurm_nodes_facts_query = 'inventory[facts] { resources { type = "Class" and title = "Ocf_hpc::Compute" } }'
    $slurm_nodes_facts = puppetdb_query($slurm_nodes_facts_query).map |$value| { $value['facts'] }

    # Hostname of the controller to pass into the template.
    # This is hacky, as it will select the first entry in the query, and assumes there is only one controller.
    # It also assumes the slurmdbd host is the same machine as the controller.
    $slurm_controller_query = 'inventory[facts] { resources { type = "Class" and title = "Ocf_hpc::Controller" } }'
    $slurm_controller_hostname = puppetdb_query($slurm_controller_query)[0]['facts']['hostname']
    file { '/etc/slurm-llnl/slurm.conf':
      content => template(
        'ocf_hpc/slurm.conf.erb',
        'ocf_hpc/nodes-partitions.erb'
      ),
      mode    => '0644',
      owner   => 'slurm',
      group   => 'slurm',
      require => Package['slurm-wlm'],
    }
  }
  # Currently all nodes contain the cgroup.conf files
  file { '/etc/slurm-llnl/cgroup.conf':
    content => template('ocf_hpc/cgroup.conf.erb'),
    mode    => '0644',
    owner   => 'slurm',
    group   => 'slurm',
  }
}
