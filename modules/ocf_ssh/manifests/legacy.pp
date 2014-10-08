class ocf_ssh::legacy {
  # Symlinks for legacy file paths
  File { ensure => link, links => manage }
  file {
    '/opt/local':
      ensure => directory,
    ;
    '/opt/local/environment':
      target => '/opt/ocf/share/environment',
    ;
    '/usr/local/environment':
      target => '/opt/ocf/share/environment',
    ;
    '/usr/ucb':
      ensure => directory,
    ;
    '/usr/ucb/whoami':
      target => '/usr/bin/whoami',
    ;
  }
}
