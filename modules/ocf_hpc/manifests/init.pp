class ocf_hpc {
  include ocf::firewall::allow_ssh
  include ocf::ipmi
  include ocf_hpc::singularity

  package { 'slurm-wlm': }

  if $::puppetdb_running {
    $slurm_nodes_facts_query = puppetdb_query('inventory[facts] { resources { type = "Class" and title = "Ocf_hpc::Compute" } }')
    # To avoid a circular dependency, fallback to empty values if no nodes match the query.
    $slurm_nodes_facts = $slurm_nodes_facts_query == undef ? {
      false => $slurm_nodes_facts_query.map |$value| { $value['facts'] },
      true  => [],
    }
    # Hostname of the controller to pass into the template.
    # This is hacky, as it will select the first entry in the query, and assumes there is only one controller.
    # It also assumes the slurmdbd host is the same machine as the controller.
    $slurm_controller_query = puppetdb_query('inventory[facts] { resources { type = "Class" and title = "Ocf_hpc::Controller" } }')
    $slurm_controller_hostname = $slurm_controller_query == undef ? {
      false => $slurm_controller_query[0]['facts']['hostname'],
      true  => '',
    }
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

  # SLURM uses MUNGE for authentication. Each host needs to have
  # the same munge.key, and have synced clocks.
  package { 'munge': } -> file { '/etc/munge/munge.key':
    source => 'puppet:///private/munge.key',
    mode   => '0400',
    owner  => 'munge',
    group  => 'munge',
  } ~> service { 'munge':
    ensure     => 'running',
    enable     => true,
    hasrestart => true,
  }
}
