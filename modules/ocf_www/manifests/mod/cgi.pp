class ocf_www::mod::cgi {
  include apache::mod::cgid
  include apache::mod::suexec

  apache::custom_config { 'cgi_options':
    content => "AddHandler cgi-script .cgi\n",
  }
}
