class ocf_hpc {
  include ocf::ipmi

  package { 'singularity-container':
    install_options => ['-t stretch-backports'],
  }

  package { 'slurm-wlm': }

  if $::puppetdb_running {
    $slurm_nodes_facts_query = 'inventory[facts] { resources { type = "Class" and title = "Ocf_hpc::compute" } }'
    $slurm_nodes_facts = puppetdb_query($::slurm_nodes_query).map |$value| { $value['facts'] }
    file { '/etc/slurm-llbl/slurm.conf':
      content => template(
        'ocf_hpc/slurm.conf.erb',
        'ocf_hpc/nodes.erb'
      ),
      mode    => '0644',
      owner   => 'slurm',
      group   => 'slurm',
      require => Package['slurm-wlm'],
    }
  }
}
