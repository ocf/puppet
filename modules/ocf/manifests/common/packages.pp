class ocf::common::packages( $extra = false, $login = false ) {

  # packages to remove
  package {
    'popularity-contest':
      ensure => purged;
    'mlocate':
      ensure => purged
  }

  # common packages for all ocf machines
  package {
    'common':
      name => [ 'beep', 'bsdmainutils', 'cpufrequtils', 'finger', 'pwgen', 'quota', 'rsync', 'tofrodos', 'tree' ];
    'shells':
      name => [ 'bash', 'tcsh', 'zsh' ];
    'screen':
      name => [ 'dtach', 'screen', 'tmux' ];
    'top':
      name => [ 'htop', 'iftop', 'iotop', 'powertop' ];
    'vim':
  }

  # extra packages for desktops and possibly a server
  if $extra {
    package {
      'build-essential':;
      'latex':
        name => [ 'pdfjam', 'texlive-latex-recommended', 'texlive-latex-extra' ];
      'nmap':;
      'pssh':;
      'vcs':
        name => [ 'git', 'mercurial', 'subversion' ]
    }
  }

  # more packages for the login server
  if $login {
    package {
      'chpass':
        name => [ 'libexpect-perl', 'libunicode-map8-perl' ];
      'db-clients':
        name => [ 'mysql-client', 'postgresql-client' ];
      'emacs23-nox':;
      'irssi':;
      'lynx':;
      'mailclients':
        name => [ 'alpine', 'mutt' ];
      'octave3.2':;
      'signat':
        name => 'libwww-mechanize-perl';
      'pykota':
        name => [ 'pkpgcounter', 'python-egenix-mxdatetime', 'python-imaging', 'python-jaxml', 'python-minimal', 'python-mysqldb', 'python-osd', 'python-pysnmp4', 'python-reportlab' ]
    }
  }

}
