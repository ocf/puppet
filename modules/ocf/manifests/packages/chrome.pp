class ocf::packages::chrome {
  include ocf::userns

  $browser_homepage = lookup('browser_homepage')

  class { 'ocf::packages::chrome::apt':
    stage => first,
  }

  package { 'google-chrome-stable':; }

  file {
    ['/etc/opt/chrome', '/etc/opt/chrome/policies', '/etc/opt/chrome/policies/managed']:
      ensure  => directory,
      require => Package['google-chrome-stable'];

    '/etc/opt/chrome/policies/managed/ocf_policy.json':
      content => template('ocf/chrome/ocf_policy.json.erb'),
      require => Package['google-chrome-stable'];

    '/opt/google/chrome/master_preferences':
      source  => 'puppet:///modules/ocf/chrome/master_preferences',
      require => Package['google-chrome-stable'];

    # Disable Google's broken cronjob which sets up the wrong apt sources
    # (rt#4589).
    '/opt/google/chrome/cron/google-chrome':
      mode    => '0755',
      content => "#!/bin/sh\n# Disabled by OCF (rt#4589)\n",
      require => Package['google-chrome-stable'];
  }
}
