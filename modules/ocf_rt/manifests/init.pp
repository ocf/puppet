class ocf_rt {
  include ocf_ssl
  include ocf_rt::apache

  package {
    'request-tracker4':
      responsefile => '/var/cache/debconf/request-tracker4.preseed',
      require      => File['/var/cache/debconf/request-tracker4.preseed'];

    ['rt4-db-mysql', 'rt4-apache2', 'cpanminus']:;
  }

  file {
    # answers to debconf questions
    '/var/cache/debconf/request-tracker4.preseed':
      source => 'puppet:///modules/ocf_rt/request-tracker4.preseed';

    '/etc/request-tracker4/RT_SiteConfig.d/98-ocfdb':
      source  => 'puppet:///private/rt-db',
      mode    => '0600',
      notify  => Exec['update-siteconfig'],
      require => Package['request-tracker4'];

    '/etc/request-tracker4/RT_SiteConfig.d/99-ocf':
      source  => 'puppet:///modules/ocf_rt/99-ocf',
      notify  => Exec['update-siteconfig'],
      require => Package['request-tracker4'];

    '/etc/rt.keytab':
      source => 'puppet:///private/rt.keytab',
      owner  => www-data,
      mode   => '0600';
  }

  exec {
    'update-siteconfig':
      command     => 'update-rt-siteconfig-4',
      refreshonly => true,
      require     => Package['request-tracker4'];

    # install RT modules from CPAN
    'install-commandbymail':
      command => 'cpanm install RT::Extension::CommandByMail',
      creates => '/usr/local/share/request-tracker4/plugins/RT-Extension-CommandByMail',
      require => Package['request-tracker4', 'cpanminus'];

    'install-mergeusers':
      command => 'cpanm install RT::Extension::MergeUsers',
      creates => '/usr/local/share/request-tracker4/plugins/RT-Extension-MergeUsers',
      require => Package['request-tracker4', 'cpanminus'];
  }

  cron { 'stalled-check':
    command => '/usr/bin/rt-crontool --search RT::Search::FromSQL --search-arg "LastUpdated < \'5 days ago\' AND Status = \'stalled\'" --action RT::Action::SetStatus --action-arg resolved --log notice',
    special => 'hourly';
  }
}
