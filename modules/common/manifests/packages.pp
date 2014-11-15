class common::packages( $extra = false, $login = false ) {

  # packages to remove
  package {
    ['mlocate', 'popularity-contest', 'apt-listchanges']:
      ensure => purged;
  }

  # common packages for all ocf machines
  package {
    # general packages
    [ 'beep', 'bsdmainutils', 'cpufrequtils', 'finger', 'netcat-openbsd', 'pigz', 'pv', 'pwgen', 'quota', 'rsync', 'tofrodos', 'tree', 'unzip', 'curl', 'vim', 'lsof' ]:;
    # account approval and chpass/passwd dependencies
    ['python-cracklib', 'python-dnspython']:;
    # common scripting languages
    ['python3', 'python3-pip', 'python3-dev', 'python-pip', 'python-dev', 'python-ldap']:;
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
      # chpass dependencies
      ['libexpect-perl', 'libunicode-map8-perl']:;

      # signat dependencies
      'libwww-mechanize-perl':;

      # pykota dependencies
      ['pkpgcounter', 'python-egenix-mxdatetime', 'python-imaging',
      'python-jaxml', 'python-minimal', 'python-mysqldb', 'python-osd',
      'python-pysnmp4', 'python-reportlab']:;

      # utilities
      [
      'alpine',
      'apache2-utils',
      'bogofilter',
      'elinks',
      'emacs23-nox',
      'irssi',
      'lynx',
      'mutt',
      'octave',
      ]:;

      # programming/scripting/development
      [
      'autoconf',
      'automake',
      'bison',
      'cgdb',
      'chicken-bin',
      'flex',
      'gdb',
      'ipython',
      'ipython3',
      'libfcgi-dev',
      'libffi-dev',
      'libgdbm-dev',
      'libncurses5-dev',
      'libpq-dev',
      'libreadline6-dev',
      'libsqlite3-dev',
      'libtidy-dev',
      'libtool',
      'libyaml-dev',
      'nodejs',
      'openjdk-7-jdk',
      'php5-cli',
      'php5-curl',
      'php5-gd',
      'php5-mcrypt',
      'php5-mysql',
      'php5-sqlite',
      'pkg-config',
      'python-django',
      'python-flask',
      'python-lxml',
      'python-pandas',
      'python-virtualenv',
      'python-yaml',
      'python3-tk',
      'r-base',
      'rails3',
      'ruby-dev',
      'ruby-sqlite3',
      'sqlite3',
      'valgrind',
      ]:;
    }
  }

}
