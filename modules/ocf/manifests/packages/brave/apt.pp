# Include Brave apt repo.
class ocf::packages::brave::apt {
  apt::key { 'brave':
    id     => '5AB4CA7AC2F93FE3EBD6082D6ED19DBB448EEE6C',
    server => 'keyserver.ubuntu.com',
  }

  apt::source { 'brave':
    architecture => 'amd64',
    location     => 'https://s3-us-west-2.amazonaws.com/brave-apt',
    release      => $::lsbdistcodename,
    repos        => 'main',
    include      => {
      src => false
    },
    require      => Apt::Key['brave'],
  }
}
