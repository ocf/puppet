# Include miniconda apt repo
class ocf_hpc::conda::apt {
  apt::keyring { 'conda.asc':
    source => 'https://repo.anaconda.com/pkgs/misc/gpgkeys/anaconda.asc',
  }


  apt::source { 'conda':
    location => 'https://repo.anaconda.com/pkgs/misc/debrepo/conda',
    release  => 'stable',
    repos    => 'main',
    keyring  => '/etc/apt/keyrings/conda.asc',
    require  => Apt::Keyring['conda.asc'];
  }
}
