class common::packages( $extra = false, $login = false ) {

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
    [ 'beep', 'bsdmainutils', 'cpufrequtils', 'finger', 'netcat-openbsd', 'pigz', 'pv', 'pwgen', 'quota', 'rsync', 'tofrodos', 'tree', 'unzip', 'apt-listchanges', 'curl', 'vim' ]:;
    # account approval and chpass/passwd dependencies
    ['python-cracklib', 'python-dnspython']:;
    # common scripting languages
    ['python3', 'python3-pip']:;
    # console managers
    [ 'dtach', 'screen' ]:;
    # shells
    [ 'bash', 'tcsh', 'zsh' ]:;
    # top
    [ 'htop', 'iperf', 'iftop', 'iotop', 'powertop' ]:;
    # network debugging
    [ 'tcpdump', 'mtr' ]:;
  }
  ocf::repackage {
    'tmux':
      backports => true;
  }

  # extra packages for desktops and possibly a server
  if $extra {
    package {
      'build-essential':;
      # latex
      [ 'pdfjam', 'texlive-latex-recommended', 'texlive-latex-extra', 'texlive-fonts-recommended' ]:;
      'nmap':;
      'pssh':;
      # version control
      # git is included in common::git
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
      'octave':;
      # pykota python dependencies
      [ 'pkpgcounter', 'python-egenix-mxdatetime', 'python-imaging', 'python-jaxml', 'python-minimal', 'python-mysqldb', 'python-osd', 'python-pysnmp4', 'python-reportlab' ]:;
      # signat.pl dependency
      'libwww-mechanize-perl':;
      # php
      ['php5-cli', 'php5-mysql', 'php5-sqlite', 'php5-gd', 'php5-curl', 'php5-mcrypt']:;
      # python
      ['ipython', 'python-dev', 'python-django', 'python-flask', 'python-ldap', 'python-lxml', 'python-virtualenv', 'python-yaml']:;
      # ruby
      ['rails3', 'ruby-dev', 'ruby-sqlite3']:;
      # scripting/programming/development packages
      ['bison', 'flex', 'ipython3', 'libncurses5-dev', 'python3-tk', 'chicken-bin', 'libfcgi-dev', 'sqlite3', 'libsqlite3-dev', 'libtidy-dev', 'nodejs', 'openjdk-7-jdk']:;
    }
  }

}
