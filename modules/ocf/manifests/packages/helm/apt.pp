# Include Helm apt repo
class ocf::packages::helm::apt {
  apt::key { 'helm repo key':
    id     => '81BF832E2F19CD2AA0471959294AC4827C1A168A',
    source => 'https://baltocdn.com/helm/signing.asc';
  }

  apt::source { 'helm':
    architecture => 'amd64',
    location     => 'https://baltocdn.com/helm/stable/debian/',
    release      => 'all',
    repos        => 'main',
    require      => Apt::Key['helm repo key'],
  }
}
