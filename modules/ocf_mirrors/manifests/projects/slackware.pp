class ocf_mirrors::projects::slackware {
  file {
    '/opt/mirrors/project/slackware':
      ensure  => directory,
      source  => 'puppet:///modules/ocf_mirrors/project/slackware',
      owner   => mirrors,
      group   => mirrors,
      mode    => '0755',
      recurse => true;
  }

  ocf_mirrors::timer {
    'slackware':
      exec_start => '/opt/mirrors/project/slackware/sync-archive',
      hour       => '0/6',
      minute     => '11',
      require    => File['/opt/mirrors/project/slackware'];
  }
}
