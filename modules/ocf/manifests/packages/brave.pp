class ocf::packages::brave {
  include ocf::userns

  $browser_homepage = lookup('browser_homepage')

  class { 'ocf::packages::brave::apt':
    stage =>  first,
  }

  package { 'brave':; }

  # TODO: Change this to a global config
  # if/when Brave adds support for it.
  file {
    '/etc/skel/.config/brave/session-store-1':
      content => template('ocf/brave/session-store-1.erb'),
      require => Package['brave'];
  }
}
