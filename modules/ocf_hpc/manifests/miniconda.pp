class ocf_hpc::miniconda {
  class { 'ocf_hpc::miniconda::apt':
    stage => first,
  }
  
  package { 'miniconda':; }
}
