class ocf::autologout {

  # autologout terminal matching $condition after $TMOUT seconds of inactivity
  $condition = 'tty | grep -q ^/dev/tty'
  $timeout = 300

  File { mode => 0755 }
  file {
    '/etc/profile.d/autologout.sh':
      content => "${condition} && export TMOUT=${timeout}",
    ;
    '/etc/profile.d/autologout.csh':
      content => "${condition} && setenv TMOUT ${timeout}",
    ;
  }

}
