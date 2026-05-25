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
      # Per-user process cap: prevents one user from exhausting the global
      # backend pool (e.g. a compromised WordPress site attracting bot traffic).
      FcgidMaxProcessesPerClass 5

      # Global backend pool cap.  With 300 Apache worker threads and each
      # request potentially blocking on a backend, keep this well under
      # MaxRequestWorkers so idle workers remain available for static files.
      FcgidMaxProcesses 200

      # Kill backends that are busy for longer than 120 s (default 300).
      FcgidBusyTimeout 120

      # Kill backends that do not send output within 40 s (default 40, but
      # stated explicitly for clarity).
      FcgidIOTimeout 40

      # Reap idle backends after 5 min instead of 1 hour so they do not
      # accumulate across hundreds of user vhosts.
      FcgidIdleTimeout 300

      # A process can live for at max an hour, whether it is idle or not
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
