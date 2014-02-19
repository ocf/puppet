class desktop::pam {
  # disable pam_faildelay
  file {
    '/etc/pam.d/common-auth':
      source => 'puppet:///modules/desktop/pam/common-auth';
    '/etc/pam.d/login':
      source => 'puppet:///modules/desktop/pam/login';
  }
}
