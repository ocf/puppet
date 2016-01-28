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
    'python-reportlab']:;

    # misc. packages helpful for users
    [
    'alpine',
    'apache2-utils',
    'autoconf',
    'automake',
    'bison',
    'bogofilter',
    'build-essential',
    'cgdb',
    'chicken-bin',
    'chrpath',
    'debhelper',
    'default-jdk',
    'elinks',
    'emacs',
    'flex',
    'gdb',
    'gem2deb',
    'iceweasel',
    'ikiwiki',
    'inotify-tools',
    'ipython',
    'ipython-notebook',
    'ipython3',
    'ipython3-notebook',
    'irssi',
    'libdbi-perl',
    'libexpect-perl',
    'libfcgi-dev',
    'libfcgi-ruby1.8',
    'libffi-dev',
    'libgdbm-dev',
    'libgtk2.0-dev',
    'libicu-dev',
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
    'lynx',
    'mercurial',
    'mutt',
    'nmap',
    'nodejs',
    'octave',
    'pandoc',
    'pdfjam',
    'php5-cli',
    'rar',
    'php5-curl',
    'php5-gd',
    'php5-mcrypt',
    'php5-mysql',
    'php5-sqlite',
    'pkg-config',
    'pssh',
    'puppet-lint',
    'python-cracklib',
    'python-crypto',
    'python-django',
    'python-flask',
    'python-flup',
    'python-lxml',
    'python-mysqldb',
    'python-nose',
    'python-numpy',
    'python-pandas',
    'python-scipy',
    'python-sklearn',
    'python-sqlalchemy',
    'python-stdeb',
    'python-sympy',
    'python-twisted',
    'python-virtualenv',
    'python-yaml',
    'python3-lxml',
    'python3-nose',
    'python3-tk',
    'quilt',
    'r-base',
    'ruby-dev',
    'ruby-mysql',
    'ruby-ronn',
    'ruby-sqlite3',
    'sqlite3',
    'subversion',
    'texlive-fonts-recommended',
    'texlive-latex-extra',
    'texlive-latex-recommended',
    'texlive-publishers',
    'texlive-science',
    'unrar',
    'vagrant',
    'valgrind',
    'zlib1g-dev',
    'znc',
    ]:;

    'autolink':
      provider => pip;

    # purge virtualbox for security reasons (setuid binaries allow network control)
    # see debian bug#760569
    'virtualbox':
      ensure => purged;
  }

  if $::lsbdistcodename == 'jessie' {
    package {
      # not available in wheezy (except backports), but we don't need them
      [
      'apache2-dev',
      'dh-systemd',
      'git-buildpackage',
      'google-gsutil',
      'libcrack2-dev',
      'libjpeg-dev',
      'lolcat',
      'pre-commit',
      'python-flake8',
      'python-mock',
      'python-pytest',
      'python-pytest-cov',
      'python3-flake8',
      'python3-flask',
      'python3-mock',
      'python3-pytest',
      'python3-pytest-cov',
      'python3-sklearn',
      'python3-stdeb',
      'python3-sympy',
      'twine',
      ]:;
    }

    ocf::repackage { 'dh-virtualenv':
      backport_on => 'jessie';
    }
  }

  # install wp-cli
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
