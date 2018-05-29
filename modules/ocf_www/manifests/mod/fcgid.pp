class ocf_www::mod::fcgid {
  include apache::mod::fcgid
  include apache::mod::suexec

  file {
    '/usr/local/bin/suexec':
      ensure => directory;

    # This wrapper script is in a separate subdirectory of /usr/local/bin so
    # that none of the other scripts/files in /usr/local/bin are allowed by our
    # suexec patch except the ones explicitly put in the suexec subdirectory
    '/usr/local/bin/suexec/php-fcgi-wrapper':
      source  => 'puppet:///modules/ocf_www/php-fcgi-wrapper',
      mode    => '0755',
      require => File['/usr/local/bin/suexec'];
  }

  apache::custom_config { 'fastcgi_options':
    content => "
      FcgidCmdOptions /usr/lib/apache2/suexec ConnectTimeout 15 MaxProcesses 1000 MinProcesses 0
      FcgidWrapper /usr/local/bin/suexec/php-fcgi-wrapper
    ",
  }
}
