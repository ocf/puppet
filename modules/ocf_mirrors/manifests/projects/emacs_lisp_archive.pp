class ocf_mirrors::projects::emacs_lisp_archive {
  file {
    default:
      ensure  =>  directory,
      owner   => mirrors,
      group   => mirrors,
      mode    => '0755',
      recurse => true;

    '/opt/mirrors/project/elpa':
      source  => 'puppet:///modules/ocf_mirrors/project/elpa/';

    '/opt/mirrors/project/melpa':
      source  => 'puppet:///modules/ocf_mirrors/project/melpa/';
  }

  ocf_mirrors::timer {
    'elpa':
      exec_start => '/opt/mirrors/project/elpa/sync-archive',
      hour       => '0/8',
      minute     => '30',
      require    => File['/opt/mirrors/project/elpa'];

    'melpa':
      exec_start => '/opt/mirrors/project/melpa/sync-archive',
      hour       => '0/8',
      minute     => '20',
      require    => File['/opt/mirrors/project/melpa'];
  }
}
