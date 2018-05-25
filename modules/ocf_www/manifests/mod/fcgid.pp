class ocf_www::mod::fcgid {
  include apache::mod::fcgid
  include apache::mod::suexec

  apache::custom_config { 'fastcgi_options':
    content => "
      FcgidCmdOptions /usr/lib/apache2/suexec ConnectTimeout 15 MaxProcesses 1000 MinProcesses 0
      FcgidWrapper /services/http/suexec/php-fcgi-wrapper
    ",
  }
}
