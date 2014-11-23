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
# without concerns of redeclaring common::packages with different parameters.
class common::extrapackages {
  package {
    # chpass dependencies
    ['libexpect-perl', 'libunicode-map8-perl', 'python-cracklib']:;

    # signat dependencies
    'libwww-mechanize-perl':;

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
    'default-jdk',
    'elinks',
    'emacs',
    'flex',
    'gdb',
    'ipython',
    'ipython-notebook',
    'ipython3',
    'ipython3-notebook',
    'irssi',
    'libdbi-perl',
    'libfcgi-dev',
    'libfcgi-ruby1.8',
    'libffi-dev',
    'libgdbm-dev',
    'libncurses5-dev',
    'libpq-dev',
    'libreadline6-dev',
    'libsqlite3-dev',
    'libtidy-dev',
    'libtool',
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
    'php5-curl',
    'php5-gd',
    'php5-mcrypt',
    'php5-mysql',
    'php5-sqlite',
    'pkg-config',
    'pssh',
    'python-crypto',
    'python-django',
    'python-flask',
    'python-flup',
    'python-lxml',
    'python-matplotlib',
    'python-mysqldb',
    'python-numpy',
    'python-pandas',
    'python-scipy',
    'python-sqlalchemy',
    'python-twisted',
    'python-virtualenv',
    'python-yaml',
    'python3-tk',
    'r-base',
    'ruby-dev',
    'ruby-mysql',
    'ruby-sqlite3',
    'sqlite3',
    'subversion',
    'texlive-fonts-recommended',
    'texlive-latex-extra',
    'texlive-latex-recommended',
    'vagrant',
    'valgrind',
    'virtualbox',
    ]:;
  }
}
