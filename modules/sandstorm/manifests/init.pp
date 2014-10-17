class sandstorm {
  include ocf_ssl

  package {
    [ 'apache2' ]:
    ;
    # php
    ['php5', 'php5-mysql', 'libapache2-mod-php5', 'php5-mcrypt']:
    ;
  }

  # apache must subscribe to all conf files
  service { 'apache2': }
}
