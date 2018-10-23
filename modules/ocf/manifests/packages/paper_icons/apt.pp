# Include Brave apt repo.
class ocf::packages::paper_icons::apt {
  apt::key { 'paper_icons':
    id     => 'D320D0C30B02E64C5B2BB2743766223989993A70',
    server => 'keyserver.ubuntu.com',
  }

  apt::source { 'paper_icons':
    architecture => 'amd64',
    location     => 'http://ppa.launchpad.net/snwh/ppa/ubuntu/',
    release      => 'cosmic',
    repos        => 'main',
    include      => {
      src => false
    },
    require      => Apt::Key['paper_icons'],
  }
}
