class common::locale {
  file {
    "/etc/locale.gen":
      content => "en_US.UTF-8 UTF-8\n";
  }

  exec {
    "locale-gen":
      subscribe => File["/etc/locale.gen"],
      refreshonly => true,
      require => File["/etc/locale.gen"];

    "update-locale LANG=en_US.UTF-8":
      subscribe => Exec["locale-gen"],
      refreshonly => true;
  }
}
