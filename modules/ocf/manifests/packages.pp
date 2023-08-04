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
  include ocf::packages::helm
  include ocf::packages::ldapvi
  include ocf::packages::ntp
  include ocf::packages::postfix
  include ocf::packages::powershell
  include ocf::packages::restic
  include ocf::packages::rsync
  include ocf::packages::shell
  include ocf::packages::ssh
  include ocf::packages::vim

  # Packages to automatically update to be the latest version. This should be
  # kept short, since apt-dater should be used to update almost all packages.
  #
  # TODO: Fix with the Raspberry Pi?
  if $facts['os']['distro']['id'] == 'Debian' {
    package {
      # Ensure ocflib is the latest version to quickly push out changes in lab
      # hours, etc. We control releases on this, so this should be safe.
      'python3-ocflib':
        ensure => latest;
    }
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

      # slows down desktop unsleeps by ~1 minute
      'avahi-daemon',
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
      'gist',
      'hexedit',
      'htop',
      'iftop',
      'iotop',
      'iperf',
      'iperf3',
      'jq',
      'lsof',
      'man-db',
      'molly-guard',
      'moreutils',
      'mtr',
      'ncdu',
      'net-tools',
      'netcat-openbsd',
      'parted',
      'pigz',
      'powertop',
      'pv',
      'pwgen',
      'python3',
      'python3-dateutil',
      'python3-dev',
      'python3-dnspython',
      'python3-paramiko',
      'python3-pip',
      'python3-requests',
      'python3-tabulate',
      'python3-venv',
      'quota',
      'ranger',
      'reptyr',
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

  # TODO: remove this once we no longer support stretch (and move to above
  # packages block)
  if $::os[distro][codename] != 'stretch' {
    package {
      'kitty-terminfo':;
    }
  }

  ocf::repackage { 'python3-attr':
    backport_on =>  ['stretch'],
  }

  ocf::repackage { 'python3-cryptography':
    backport_on => ['stretch'],
  }

  ocf::repackage { 'python3-ldap3':
    backport_on => ['stretch'],
  }
  # only install the python3.7 packages on stretch
  # python3 is python3.7 on buster and python3.9 on bullseye

  # install elts kernel on stretch
  if $facts['os']['distro']['codename'] == 'stretch' {
    package {
        [
        'python3.7',
        'python3.7-dev',
        'python3.7-venv',
        'linux-image-5.10-amd64',
        ]:;
      }
  }
  # Packages to only install on Debian (not on Raspbian for example)
  if $facts['os']['distro']['id'] == 'Debian' {
    package {
      [
        'aactivator',
        'fluffy',
      ]:;
    }
  }
}
