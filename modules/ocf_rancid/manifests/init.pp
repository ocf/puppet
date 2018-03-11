# Configure rancid, for diffing and storing of OCF network configs.
class ocf_rancid {
  package { 'rancid':; }

  exec {
    'rancid-add-ocf-group':
      command => 'echo "LIST_OF_GROUPS=\"ocf\"" >> /etc/rancid/rancid.conf',
      unless  => 'grep -q ^LIST_OF_GROUPS /etc/rancid/rancid.conf',
      require => Package['rancid'];

    'rancid-filter-passwords':
      command => 'echo "FILTER_PWDS=ALL; export FILTER_PWDS" >> /etc/rancid/rancid.conf',
      unless  => 'grep -q ^FILTER_PWDS /etc/rancid/rancid.conf',
      require => Package['rancid'];

    'rancid-set-vcs-git':
      command => 'sed -i s/RCSSYS=cvs/RCSSYS=git/ /etc/rancid/rancid.conf',
      unless  => 'grep -q ^RCSSYS=git /etc/rancid/rancid.conf',
      require => Package['rancid'];
  }

  file {
    '/var/lib/rancid/ocf/router.db':
      content => "blackhole;cisco;up\n",
      owner   => 'rancid',
      group   => 'rancid',
      require => Package['rancid'];

    '/var/lib/rancid/.cloginrc':
      source    => 'puppet:///private/cloginrc',
      owner     => 'rancid',
      group     => 'rancid',
      mode      => '0600',
      show_diff => false,
      require   => Package['rancid'];
  }

  cron { 'rancid-run':
    command => 'rancid-run',
    user    => 'rancid',
    special => 'hourly',
    require => Package['rancid'],
  }

  # Delete all logs older than 14 days.
  # This would be better with logrotate, but the log files contain the date in
  # their name, which logrotate doesn't handle very well. The files aren't large
  # at all, so they don't need to be compressed, there's just a lot of them
  # since they are created once for every hour.
  cron { 'clean-rancid-logs':
    command => 'find /var/log/rancid/* -mtime +14 -delete > /dev/null',
    user    => 'rancid',
    special => 'hourly',
    require => Package['rancid'],
  }

  # Don't push to GitHub for dev-* hosts to prevent duplicate backups with
  # different commit hashes
  if $::host_env == 'prod' {
    # GitHub deploy hook and key
    file {
      '/var/lib/rancid/.ssh':
        ensure => directory,
        owner  => 'rancid',
        group  => 'rancid',
        mode   => '0700';

      '/var/lib/rancid/.ssh/id_rsa':
        source    => 'puppet:///private/id_rsa',
        owner     => 'rancid',
        group     => 'rancid',
        mode      => '0600',
        show_diff => false;
    }
  }
}
