class ocf_hpc::conda {
  class { 'ocf_hpc::conda::apt':
    stage => first,
  }

  package { 'conda':; }
}
