# Include Sublime Text apt repo.
class ocf::packages::sublime::apt {
  apt::keyring { 'sublime.gpg':
    source => 'https://download.sublimetext.com/sublimehq-pub.gpg',
  }

  apt::source { 'sublime':
    architecture => 'amd64',
    location     => 'https://download.sublimetext.com/ apt/stable/',
    release      => '',
    repos        => '',
    keyring      => '/etc/apt/keyrings/sublime.gpg',
    require      => Apt::Keyring['sublime.gpg'],
  }
}
