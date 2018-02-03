class ocf::walldeny {

  # disable wall command for all users except root
  file {
    '/usr/bin/wall':
      owner => root,
      mode  => '0700';
  }

}
