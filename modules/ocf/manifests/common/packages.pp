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
    [ 'beep', 'bsdmainutils', 'cpufrequtils', 'finger', 'netcat-openbsd', 'pigz', 'pv', 'pwgen', 'quota', 'rsync', 'tofrodos', 'tree', 'unzip' ]:;
    # account approval and chpass/passwd dependencies
    ['python-cracklib', 'python-dnspython']:;
    # console managers
    [ 'dtach', 'screen', 'tmux' ]:;
    # shells
    [ 'bash', 'tcsh', 'zsh' ]:;
    # top
    [ 'htop', 'iperf', 'iftop', 'iotop', 'powertop' ]:;
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
      # git is included in ocf::common::git
      [ 'mercurial', 'subversion' ]:
    }
  }

  # more packages for the login server
  if $login {
    package {
      # chpass perl dependencies
      [ 'libexpect-perl', 'libunicode-map8-perl' ]:;
      'emacs23-nox':;
      # apache utilities (such as htpasswd)
      [ 'apache2-utils' ]:;
      # irc clients
      'irssi':;
      # text web browsers
      [ 'elinks', 'lynx' ]:;
      # mail clients
      [ 'alpine', 'bogofilter', 'mutt' ]:;
      'octave3.2':;
      # pykota python dependencies
      [ 'pkpgcounter', 'python-egenix-mxdatetime', 'python-imaging', 'python-jaxml', 'python-minimal', 'python-mysqldb', 'python-osd', 'python-pysnmp4', 'python-reportlab' ]:;
      # signat.pl dependency
      'libwww-mechanize-perl':;
      # php
      'php5-cli':;
      # python
      ['ipython', 'python-dev', 'python-django', 'python-flask', 'python-ldap', 'python-lxml', 'python-yaml']:;
      # ruby
      'rails':;
      # useful for CS classes
      [ 'bison', 'flex', 'libncurses5-dev', 'python3' ]:;
    }
  }

}
