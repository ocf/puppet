# Include Sublime Text apt repo.
class ocf::packages::sublime::apt {
  apt::key { 'sublime':
    id     => '1EDDE2CDFC025D17F6DA9EC0ADAE6AD28A8F901A',
    source => 'https://download.sublimetext.com/sublimehq-pub.gpg',
  }

  apt::source { 'sublime':
    architecture => 'amd64',
    location     => 'https://download.sublimetext.com/ apt/stable/',
    require      => Apt::Key['sublime'],
  }
}
