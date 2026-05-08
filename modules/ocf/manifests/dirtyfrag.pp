# Mitigate CVE-less Dirty Frag Linux LPE
# https://github.com/V4bel/dirtyfrag
#
# Disables the esp4, esp6, and rxrpc kernel modules which are exploited
# by the Dirty Frag vulnerability to gain root privileges.
class ocf::dirtyfrag {
  file { '/etc/modprobe.d/dirtyfrag.conf':
    owner  => root,
    group  => root,
    mode   => '0644',
    source => 'puppet:///modules/ocf/modprobe.d/dirtyfrag.conf',
  }

  exec { 'remove-dirtyfrag-modules':
    command     => 'rmmod esp4 esp6 rxrpc 2>/dev/null; true',
    path        => ['/sbin', '/usr/sbin', '/bin', '/usr/bin'],
    subscribe   => File['/etc/modprobe.d/dirtyfrag.conf'],
    refreshonly => true,
  }
}
