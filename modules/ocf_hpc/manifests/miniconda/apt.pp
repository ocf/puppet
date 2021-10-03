# Include miniconda apt repo
class ocf_hpc::miniconda::apt {
  apt::key { 'miniconda':
    ensure => refreshed,
    id     => '34161F5BF5EB1D4BFBBB8F0A8AEB4F8B29D82806',
    source => 'https://repo.anaconda.com/pkgs/misc/gpgkeys/anaconda.asc',
  }


  apt::source { 'miniconda':
    location => 'https://repo.anaconda.com/pkgs/misc/debrepo/conda',
    release  => 'stable',
    repos    => 'main',
    require  => Apt::Key['miniconda'];
  }
}
