class ocf::packages::brave {
  include ocf::userns

  $browser_homepage = lookup('browser_homepage')

  class { 'ocf::packages::brave::apt':
    stage =>  first,
  }

  # New install instructions, per https://brave-browser.readthedocs.io/en/latest/installing-brave.html#linux
  package { 'brave-browser':; } ->

  # TODO: Change this to a global config
  # if/when Brave adds support for it.
  file {
    [
      '/etc/skel/.config/BraveSoftware/',
      '/etc/skel/.config/BraveSoftware/Brave-Browser/',
      '/etc/skel/.config/BraveSoftware/Brave-Browser/Default'
    ]:
      ensure  => directory,
      require => File['/etc/skel/.config'],
  } ->

  file {
    '/etc/skel/.config/BraveSoftware/Brave-Browser/Default/Preferences':
      content => template('ocf/brave/Preferences.erb'),
  }
}
