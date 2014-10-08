class desktop::chrome {
  if $::lsbdistcodename != 'jessie' {
    file {
      ['/etc/opt/chrome', '/etc/opt/chrome/policies', '/etc/opt/chrome/policies/managed']:
        ensure  => directory,
        require => Package['google-chrome-stable'],
      ;
      '/etc/opt/chrome/policies/managed/ocf_policy.json':
        source  => 'puppet:///modules/desktop/chrome/ocf_policy.json',
        require => Package['google-chrome-stable'],
      ;
      '/opt/google/chrome/master_preferences':
        source  => 'puppet:///modules/desktop/chrome/master_preferences',
        require => Package['google-chrome-stable'],
      ;
    }

    package { 'google-chrome-stable':; }
  }
}
