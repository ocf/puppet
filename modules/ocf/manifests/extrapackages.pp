# Packages to be installed on user-facing machines.
#
# In order to avoid confusing users (and to be as convenient as possible), we
# maintain a common set of packages between "login" servers, desktops, and web
# servers.
#
# Some of these packages don't make sense in some of these environments, but
# the marginal cost of installing useless packages is low, and it's easier to
# maintain this one config (and better for users in at least some cases).
#
# This is in a separate manifest so that it can be included by other modules
# without concerns of redeclaring ocf::packages with different parameters.
class ocf::extrapackages {
  # special snowflake packages that require some config
  include ocf::packages::matplotlib
  include ocf::packages::mysql
  include ocf::packages::mysql_server
  include ocf::packages::nmap

  # other packages
  package {
    # misc. packages helpful for users
    [
    'alpine',
    'apache2-dev',
    'apache2-utils',
    'autoconf',
    'autojump',
    'automake',
    'bison',
    'bogofilter',
    'build-essential',
    'cabal-install',
    'cgdb',
    'chicken-bin',
    'chrpath',
    'cmake',
    'cowsay',
    'debhelper',
    'default-jdk',
    'dh-systemd',
    'elinks',
    'emacs',
    'flex',
    'fortune-mod',
    'gdb',
    'gem2deb',
    'ghc',
    'git-buildpackage',
    'golang',
    'graphviz',
    'icedtea-netx',
    'ikiwiki',
    'inotify-tools',
    'intltool',
    'ipython',
    'ipython3',
    'irssi',
    'libcrack2-dev',
    'libdbi-perl',
    'libexpect-perl',
    'libfcgi-dev',
    'libffi-dev',
    'libgdbm-dev',
    'libgtk-3-dev',
    'libgtk2.0-dev',
    'libicu-dev',
    'libjpeg-dev',
    'liblua5.1-0-dev',
    'libmagickwand-dev',
    'libncurses5-dev',
    'libopencv-dev',
    'libpq-dev',
    'libreadline-dev',
    'libsqlite3-dev',
    'libtidy-dev',
    'libtool',
    'libunicode-map8-perl',
    'libwww-mechanize-perl',
    'libxml2-dev',
    'libxslt1-dev',
    'libyaml-dev',
    'lolcat',
    'lynx',
    'maven',
    'mercurial',
    'mosh',
    'mutt',
    'nasm',
    'nodejs',
    'octave',
    'pandoc',
    'pdfchain',
    'pkg-config',
    'pkpgcounter',
    'postgresql-client',
    'pssh',
    'puppet-lint',
    'python-cracklib',
    'python-crypto',
    'python-django',
    'python-egenix-mxdatetime',
    'python-flake8',
    'python-flask',
    'python-flup',
    'python-imaging',
    'python-jaxml',
    'python-lxml',
    'python-minimal',
    'python-mock',
    'python-mysqldb',
    'python-nose',
    'python-numpy',
    'python-pandas',
    'python-progressbar',
    'python-pysnmp4',
    'python-pysqlite2',
    'python-pytest',
    'python-pytest-cov',
    'python-reportlab',
    'python-scapy',
    'python-scipy',
    'python-sklearn',
    'python-sqlalchemy',
    'python-stdeb',
    'python-sympy',
    'python-twisted',
    'python-virtualenv',
    'python-yaml',
    'python3-flake8',
    'python3-flask',
    'python3-jinja2',
    'python3-lxml',
    'python3-mock',
    'python3-mysqldb',
    'python3-nose',
    'python3-progressbar',
    'python3-pytest',
    'python3-pytest-cov',
    'python3-stdeb',
    'python3-sympy',
    'python3-tk',
    'quilt',
    'r-base',
    'r10k',
    'rails',
    'r-cran-data.table',
    'r-cran-ggplot2',
    'r-cran-jsonlite',
    'r-cran-lubridate',
    'r-cran-magrittr',
    'r-cran-markdown',
    'r-cran-xml2',
    'r-cran-zoo',
    'ruby-dev',
    'ruby-fcgi',
    'ruby-ronn',
    'ruby-sqlite3',
    'scala',
    'screenfetch',
    'shellcheck',
    'silversearcher-ag',
    'sqlite3',
    'subversion',
    'texlive-extra-utils',
    'texlive-fonts-recommended',
    'texlive-humanities',
    'texlive-latex-extra',
    'texlive-latex-recommended',
    'texlive-publishers',
    'texlive-science',
    'twine',
    'vagrant',
    'valgrind',
    'weechat',
    'xvnc4viewer',
    'zlib1g-dev',
    'znc',
    ]:;
  }

  if $::lsbdistcodename == 'jessie' {
    package {
      [
        # Renamed to "ack" in stretch
        'ack-grep',

        # Replaced by jupyter-* packages in stretch with separate ipykernel
        # packages. We install python*-notebook in stretch which depend on
        # the ipykernel packages.
        'ipython-notebook',
        'ipython3-notebook',

        # These have been replaced by more generic php-* instead of php5-*
        # packages in stretch.
        'php5-cli',
        'php5-curl',
        'php5-gd',
        'php5-mcrypt',
        'php5-mysql',
        'php5-sqlite',

        # We should probably package this for stretch, since it's useful to have
        # with puppet without having to have a whole virtualenv just for that.
        # It would probably be pretty easy to package too...
        'pre-commit',

        # Replaced by ruby-mysql2 in stretch
        'ruby-mysql',

        # Replaced by default-libmysqlclient-dev in stretch
        # (it's actually in jessie backports, but not worth the headache)
        'libmysqlclient-dev',
      ]:;
    }
  } else {
    package {
      [
        'ack',
        'jupyter-console',
        'jupyter-core',
        'jupyter-notebook',
        'php-cli',
        'php-curl',
        'php-gd',
        'php-mcrypt',
        'php-mysql',
        'php-sqlite3',
        'python-notebook',
        'python3-notebook',
        'ruby-mysql2',
        'default-libmysqlclient-dev',
      ]:;
    }
  }

  ocf::repackage { 'dh-virtualenv':
    backport_on => 'jessie',
  }

  ocf::repackage { 'r-cran-dplyr':
      backport_on => 'jessie';
  } ->
  package { 'r-cran-tidyr': }

  if $::lsbdistcodename == 'jessie' {
    # We add python3.5 and tox2  on jessie so we can test our code against it
    # (in preparation for stretch).
    package {
      ['python3.5', 'python3.5-dev']:;
      'python-tox':
        ensure  => purged;
      'tox':
        require => Package['python-tox'];
    }
  } else {
    package { 'tox':; }
  }

  # install wp-cli
  # TODO: can we debian-package this?
  file { '/usr/local/sbin/download-wp-cli':
    source  => 'puppet:///modules/ocf/packages/download-wp-cli',
    mode    => '0755';
  }
  cron { 'download-wp-cli':
    command => '/usr/local/sbin/download-wp-cli',
    special => 'weekly',
    require => File['/usr/local/sbin/download-wp-cli'];
  }
  exec { 'download-wp-cli':
    command => '/usr/local/sbin/download-wp-cli',
    creates => '/usr/local/bin/wp',
    require => File['/usr/local/sbin/download-wp-cli'];
  }
}
