class ocf::common::packages( $extra = false, $login = false ) {

  # packages to remove
  package {
    'mlocate':
      ensure => purged;
    'popularity-contest':
      ensure => purged
  }

  # common packages for all ocf machines
  package {
    # general packages
    [ 'beep', 'bsdmainutils', 'cpufrequtils', 'finger', 'pwgen', 'quota', 'rsync', 'tofrodos', 'tree' ]:;
    # console managers
    [ 'dtach', 'screen', 'tmux' ]:;
    # shells
    [ 'bash', 'tcsh', 'zsh' ]:;
    # top
    [ 'htop', 'iftop', 'iotop', 'powertop' ]:;
    'vim':
  }

  # extra packages for desktops and possibly a server
  if $extra {
    package {
      'build-essential':;
      # latex
      [ 'pdfjam', 'texlive-latex-recommended', 'texlive-latex-extra' ]:;
      'nmap':;
      'pssh':;
      # version control
      [ 'git', 'mercurial', 'subversion' ]:
    }
  }

  # more packages for the login server
  if $login {
    package {
      # chpass perl dependencies
      [ 'libexpect-perl', 'libunicode-map8-perl' ]:;
      # database clients
      [ 'mysql-client', 'postgresql-client' ]:;
      'emacs23-nox':;
      'irssi':;
      'lynx':;
      # mail clients
      [ 'alpine', 'mutt' ]:;
      'octave3.2':;
      # pykota python dependencies
      [ 'pkpgcounter', 'python-egenix-mxdatetime', 'python-imaging', 'python-jaxml', 'python-minimal', 'python-mysqldb', 'python-osd', 'python-pysnmp4', 'python-reportlab' ]:;
      # signat perl dependency
      'libwww-mechanize-perl':
    }
  }

}
