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

    # idempotent command to update rancid cvs groups
    'rancid-cvs-update':
      command     => '/var/lib/rancid/bin/rancid-cvs',
      user        => 'rancid',
      refreshonly => true,
      require     => Package['rancid'],
      subscribe   => [
        Package['rancid'],
        Exec['rancid-add-ocf-group'],
      ];
  }

  file {
    '/var/lib/rancid/ocf/router.db':
      content => "blackhole:cisco:up\n",
      owner   => 'rancid',
      group   => 'rancid',
      require => [
        Package['rancid'],
        Exec['rancid-cvs-update'],
      ];

    '/var/lib/rancid/.cloginrc':
      source  => 'puppet:///private/cloginrc',
      owner   => 'rancid',
      group   => 'rancid',
      mode    => '0600',
      require => Package['rancid'];
  }

  cron { 'rancid-run':
    command => 'rancid-run',
    user    => 'rancid',
    special => 'hourly',
    require => Package['rancid'],
  }
}
