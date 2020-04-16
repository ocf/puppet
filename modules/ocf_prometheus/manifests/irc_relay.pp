class ocf_prometheus::irc_relay {
  ocf::repackage {'golang':
    backport_on => 'stretch', # Requires Go 1.9+
  }

  $repo = 'github.com/google/alertmanager-irc-relay'
  exec { 'alertmanager-irc-relay':
    command     => "go get ${repo}",
    creates     => '/usr/local/bin/alertmanager-irc-relay',
    environment => ['GOBIN=/usr/local/bin/', 'GOPATH=/tmp/go'],
    require     => Package['golang'],
  }



}
