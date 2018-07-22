class ocf::packages::grafana::apt {
  apt::key { 'grafana':
    id     => '418A7F2FB0E1E6E7EABF6FE8C2E73424D59097AB',
    source => 'https://packagecloud.io/gpg.key',
  }

  apt::source { 'grafana':
    location => 'https://packagecloud.io/grafana/stable/debian/',
    release  => 'stretch',
    repos    => 'main',
    require  => Apt::Key['grafana'],
  }
}
