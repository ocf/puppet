# Include Google Chrome apt repo.
class ocf::packages::chrome::apt {
  apt::key { 'google':
    id     => '4CCA1EAF950CEE4AB83976DCA040830F7FAC5991',
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
      require     => Apt::Key['google'];
  }
}
