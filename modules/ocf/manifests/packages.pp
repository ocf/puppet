# Packages to be installed on all OCF systems.
#
# If a package is only needed on user-facing machines, consider adding it to
# ocf::extrapackages instead. If the package would be convenient to staff
# working on other servers, though, don't hesitate to add it here.
#
# We want to keep this list small, but not to the point of omitting useful
# tools such that server maintenance becomes unnecessarily painful.
class ocf::packages {
  # packages to remove
  package {['mlocate', 'popularity-contest', 'apt-listchanges', 'needrestart']:
    ensure => purged;
  }

  # we don't want needrestart, which apt-dater-host recommends
  ocf::repackage { 'apt-dater-host':
    recommends => false;
  }

  # facter currently outputs strings not booleans
  # see http://projects.puppetlabs.com/issues/3704
  if str2bool($::is_virtual) {
    package { 'cryptsetup':; }
  }

  # common packages for all ocf machines
  package {
    [
    # general tools and utilities
    'bash',
    'beep',
    'bsdmainutils',
    'cpufrequtils',
    'curl',
    'dtach',
    'finger',
    'gist',  # not in wheezy, but in our apt repo
    'htop',
    'iftop',
    'iotop',
    'iperf',
    'lsof',
    'mtr',
    'netcat-openbsd',
    'pigz',
    'powertop',
    'pv',
    'pwgen',
    'quota',
    'rsync',
    'screen',
    'tcpdump',
    'tcsh',
    'tofrodos',
    'tree',
    'unzip',
    'vim',
    'zsh',

    # packages/libraries expected to be available everywhere
    'python',
    'python-colorama',
    'python-dateutil',
    'python-dev',
    'python-dnspython',
    'python-ldap',
    'python-pip',
    'python-requests',
    'python3',
    'python3-dateutil',
    'python3-dev',
    'python3-pip',
    'python3-requests',
    ]:;

    # python-paramiko in wheezy is incompatible with openssh >= 6.7,
    # so we install the latest version via pip (rt#3056)
    'paramiko':
      ensure   => '1.15.1',
      provider => pip;

    'python-paramiko':
      ensure => purged;
  }

  if $::lsbdistcodename == 'jessie' {
    # in jessie, install python-pip-whl to avoid problems where a system-wide
    # python module (e.g. requests) is updated, resulting in pip breaking
    # (see rt#3268, Debian #744145)
    package { 'python-pip-whl':; }
  }

  ocf::repackage {
    ['tmux']:
      backports => true;
  }
}
