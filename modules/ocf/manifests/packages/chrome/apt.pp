# Include Google Chrome apt repo.
class ocf::packages::chrome::apt {
  apt::key {
    'google-2007':
      id     => '4CCA1EAF950CEE4AB83976DCA040830F7FAC5991',
      source => 'https://dl-ssl.google.com/linux/linux_signing_key.pub';

    'google-2016':
      id     => 'EB4C1BFD4F042F6DDDCCEC917721F63BD38B4796',
      source => 'https://dl-ssl.google.com/linux/linux_signing_key.pub';
  }

  # Chrome creates /etc/apt/sources.list.d/google-chrome.list upon
  # installation, so we use the name 'google-chrome' to avoid duplicates
  #
  # Chrome will overwrite the puppet apt source during install, but puppet
  # will later change it back. They say the same thing so it's cool.
  apt::source {
    'google-chrome':
      location    => '[arch=amd64] http://dl.google.com/linux/chrome/deb/',
      release     => 'stable',
      repos       => 'main',
      include   => {
        src => false
      },
      require     => Apt::Key['google-2007', 'google-2016'];
  }
}
