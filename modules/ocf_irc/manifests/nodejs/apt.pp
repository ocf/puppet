class ocf_irc::nodejs::apt {
  package {
    'apt-transport-https':;
  }

  # Install a newer version of Node.js for the Slack bridge and web IRC app
  #
  # TODO: Remove this when we move to stretch, since it bundles nodejs 4.x, which
  # is a high enough version to run the web IRC
  apt::key { 'nodejs':
    id     => '9FD3B784BC1C6FC31A8A0A1C1655A0AB68576280',
    source => 'https://deb.nodesource.com/gpgkey/nodesource.gpg.key';
  }

  apt::source { 'nodejs':
    location => 'https://deb.nodesource.com/node_6.x',
    release  => $::lsbdistcodename,
    repos    => 'main',
    require  => [Package['apt-transport-https'], Apt::Key['nodejs']];
  }
}
