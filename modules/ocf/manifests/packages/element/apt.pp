# Include Element apt repo.
class ocf::packages::element::apt {
  apt::source { 'element':
    architecture => 'amd64',
    location     => 'https://packages.element.io/debian/',
    release      => 'default',
    repos        => 'main',
    keyring      => '/usr/share/keyrings/element-io-archive-keyring.gpg',
  }
}
