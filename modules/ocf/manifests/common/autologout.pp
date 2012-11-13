class ocf::common::autologout {

  # autologout terminal matching $condition after $TMOUT seconds of inactivity
  $condition = 'tty | grep -q ^/dev/tty'
  $TMOUT = 300

  File { mode => 0755 }
  file {
    '/etc/profile.d/autologout.sh':
      content => "$condition && export TMOUT=$TMOUT",
    ;
    '/etc/profile.d/autologout.csh':
      content => "$condition && setenv TMOUT $TMOUT",
    ;
  }

}
