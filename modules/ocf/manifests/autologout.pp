class ocf::autologout {

  # autologout terminal matching $condition after $TMOUT seconds of inactivity
  $condition = 'tty | grep -q ^/dev/tty'
  $timeout = 300

  file {
    '/etc/profile.d/autologout.sh':
      mode    => '0755',
      content => "${condition} && export TMOUT=${timeout}";

    '/etc/profile.d/autologout.csh':
      mode    => '0755',
      content => "${condition} && setenv TMOUT ${timeout}";
  }

}
