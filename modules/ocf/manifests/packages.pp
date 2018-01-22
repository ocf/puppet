# Packages to be installed on all OCF systems.
#
# If a package is only needed on user-facing machines, consider adding it to
# ocf::extrapackages instead. If the package would be convenient to staff
# working on other servers, though, don't hesitate to add it here.
#
# We want to keep this list small, but not to the point of omitting useful
# tools such that server maintenance becomes unnecessarily painful.
class ocf::packages {
  # special snowflake packages that require some config
  include ocf::packages::git
  include ocf::packages::grub
  include ocf::packages::ldapvi
  include ocf::packages::ntp
  include ocf::packages::postfix
  include ocf::packages::rsync
  include ocf::packages::shell
  include ocf::packages::ssh
  include ocf::packages::vim

  # Packages to automatically update to be the latest version. This should be
  # kept short, since apt-dater should be used to update almost all packages.
  package {
    # Ensure ocflib is the latest version to quickly push out changes in lab
    # hours, etc. We control releases on this, so this should be safe.
    'python3-ocflib':
      ensure => latest;
  }

  # Packages to remove
  package {
    [
      'apt-listchanges',
      'mlocate',
      'needrestart',
      'popularity-contest',

      # Pops up with an annoying search thing on desktop login
      'gnome-do',

      # nonfree shareware with "40-day trial"
      'rar',
      'unrar',
    ]:
      ensure => purged;
  }

  # Many staff want virtualbox for class projects (e.g. for CS161 and 162), so
  # keep it installed if this is a staff VM. Otherwise, remove it for security
  # reasons (setuid binaries allow network control). See debian bug#760569
  if $::type != 'staffvm' {
    package {
      'virtualbox':
        ensure => purged;
    }
  }

  # files we don't want on *any* server
  file {
    # The Django bash completion script is extremely slow and does a "whereis
    # python" which can block if some NFS is not available (or not fast).
    #
    # This was leading to very slow logins to tsunami for quite some time.
    '/etc/bash_completion.d/django_bash_completion':
      ensure => absent;
  }

  # common packages for all ocf machines
  package {
    [
    'aactivator',
    'apt-dater-host',
    'beep',
    'bsdmainutils',
    'cpufrequtils',
    'cryptsetup',
    'curl',
    'debian-security-support',
    'dnsutils',
    'dtach',
    'finger',
    'fluffy',
    'gist',
    'hexedit',
    'htop',
    'iftop',
    'iotop',
    'iperf',
    'jq',
    'lsof',
    'moreutils',
    'mtr',
    'netcat-openbsd',
    'pigz',
    'powertop',
    'pv',
    'pwgen',
    'python',
    'python-colorama',
    'python-dateutil',
    'python-dev',
    'python-dnspython',
    'python-ldap',
    'python-paramiko',
    'python-pip',
    'python-requests',
    'python3',
    'python3-dateutil',
    'python3-dev',
    'python3-paramiko',
    'python3-pip',
    'python3-requests',
    'python3-tabulate',
    'qrencode',
    'quota',
    'screen',
    'systemd-sysv',
    'tcpdump',
    'time',
    'tmux',
    'tofrodos',
    'tree',
    'unzip',
    'whois',
    ]:;
  }

  ocf::repackage {
    'python3-dnspython':
      backport_on => jessie,
  }

  if $::lsbdistcodename == 'jessie' {
    package {
      # in jessie, install python-pip-whl to avoid problems where a system-wide
      # python module (e.g. requests) is updated, resulting in pip breaking
      # (see rt#3268, Debian #744145)
      'python-pip-whl':;
    }
  }
}
