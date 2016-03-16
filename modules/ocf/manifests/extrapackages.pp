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

  # other packages
  package {
    # pykota dependencies
    ['pkpgcounter', 'python-egenix-mxdatetime', 'python-imaging',
    'python-jaxml', 'python-minimal', 'python-osd', 'python-pysnmp4',
    'python-reportlab', 'python-pysqlite2']:;

    # misc. packages helpful for users
    [
    'alpine',
    'apache2-dev',
    'apache2-utils',
    'autoconf',
    'automake',
    'bison',
    'bogofilter',
    'build-essential',
    'cabal-install',
    'cgdb',
    'chicken-bin',
    'chrpath',
    'debhelper',
    'default-jdk',
    'dh-systemd',
    'elinks',
    'emacs',
    'flex',
    'gdb',
    'gem2deb',
    'ghc',
    'git-buildpackage',
    'google-gsutil',
    'iceweasel',
    'ikiwiki',
    'inotify-tools',
    'ipython',
    'ipython-notebook',
    'ipython3',
    'ipython3-notebook',
    'irssi',
    'libcrack2-dev',
    'libdbi-perl',
    'libexpect-perl',
    'libfcgi-dev',
    'libfcgi-ruby1.8',
    'libffi-dev',
    'libgdbm-dev',
    'libgtk2.0-dev',
    'libicu-dev',
    'libjpeg-dev',
    'liblua5.1-0-dev',
    'libmagickwand-dev',
    'libmysqlclient-dev',
    'libncurses5-dev',
    'libopencv-dev',
    'libpq-dev',
    'libreadline6-dev',
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
    'mercurial',
    'mutt',
    'nmap',
    'nodejs',
    'octave',
    'pandoc',
    'pdfjam',
    'php5-cli',
    'php5-curl',
    'php5-gd',
    'php5-mcrypt',
    'php5-mysql',
    'php5-sqlite',
    'pkg-config',
    'pre-commit',
    'pssh',
    'puppet-lint',
    'python-cracklib',
    'python-crypto',
    'python-django',
    'python-flake8',
    'python-flask',
    'python-flup',
    'python-lxml',
    'python-mock',
    'python-mysqldb',
    'python-nose',
    'python-numpy',
    'python-pandas',
    'python-progressbar',
    'python-pytest',
    'python-pytest-cov',
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
    'rails',
    'ruby-dev',
    'ruby-mysql',
    'ruby-ronn',
    'ruby-sqlite3',
    'screenfetch',
    'sqlite3',
    'subversion',
    'texlive-fonts-recommended',
    'texlive-latex-extra',
    'texlive-latex-recommended',
    'texlive-publishers',
    'texlive-science',
    'twine',
    'vagrant',
    'valgrind',
    'xvnc4viewer',
    'zlib1g-dev',
    'znc',
    ]:;
  }

  ocf::repackage { 'dh-virtualenv':
    backport_on => 'jessie';
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
