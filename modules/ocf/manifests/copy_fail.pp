# CVE-2026-31431 (Copy Fail) mitigation.
#
# Prevents loading the algif_aead kernel module, which exposes a privilege
# escalation via AF_ALG + splice() page cache corruption. An unprivileged
# local user can corrupt the page cache of setuid binaries to obtain root.
#
# The long-term fix is a patched kernel; this class provides an immediate
# mitigation by blocking the vulnerable module from loading.
class ocf::copy_fail {
  file { '/etc/modprobe.d/disable-algif-aead.conf':
    owner  => root,
    group  => root,
    mode   => '0644',
    source => 'puppet:///modules/ocf/modprobe.d/disable-algif-aead.conf',
  }

  # Unload the module if it is currently loaded.
  exec { 'rmmod algif_aead':
    command => '/sbin/rmmod algif_aead',
    onlyif  => '/bin/grep -q "^algif_aead " /proc/modules',
    require => File['/etc/modprobe.d/disable-algif-aead.conf'],
  }
}
