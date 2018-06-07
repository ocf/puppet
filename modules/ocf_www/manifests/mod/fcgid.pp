class ocf_www::mod::fcgid {
  include apache::mod::fcgid
  include apache::mod::suexec

  package { 'python3-psutil':; }

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

    '/usr/local/bin/fcgi-restarter':
      source  => 'puppet:///modules/ocf_www/fcgi-restarter',
      mode    => '0754',
      notify  => Service['fcgi-restarter'],
      require => Package['python3-psutil'];
  }

  ocf::systemd::service { 'fcgi-restarter':
    source  => 'puppet:///modules/ocf_www/fcgi-restarter.service',
    require => File['/usr/local/bin/fcgi-restarter'],
  }

  apache::custom_config { 'fcgid_options':
    content => '
      # A process can live for at max an hour, whether it is idle or not
      FcgidIdleTimeout 3600
      FcgidProcessLifeTime 3600

      # After 200 requests, a process will be killed off (and another spawned
      # on the next request), to protect from memory leaks
      FcgidMaxRequestsPerProcess 200

      # The default for this is 3, not 0, meaning that processes will linger
      # forever when started, but with many users this does not work
      FcgidMinProcessesPerClass 0

      # Set the default max request size to 1 GiB, so that uploads are not
      # blocked. Otherwise, the default here is something ridiculously low,
      # like 128 KiB
      FcgidMaxRequestLen 1073741824

      # These are specified individually because .fcgi files do not use this
      # wrapper and there is no regex option for it
      FcgidWrapper /usr/local/bin/suexec/php-fcgi-wrapper .php
      FcgidWrapper /usr/local/bin/suexec/php-fcgi-wrapper .php3
      FcgidWrapper /usr/local/bin/suexec/php-fcgi-wrapper .php4
      FcgidWrapper /usr/local/bin/suexec/php-fcgi-wrapper .php5
      FcgidWrapper /usr/local/bin/suexec/php-fcgi-wrapper .php7
      FcgidWrapper /usr/local/bin/suexec/php-fcgi-wrapper .phtml
    ',
  }
}
