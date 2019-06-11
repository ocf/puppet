# Ceph object store daemon configuration
# Set ocf_ceph::osd::disks to be the disks allocated to ceph
# Sometimes while applying the configuration, there might be an error
# "Can't open /dev/sdx exclusively. Mounted filesystem?"
# If that is the case, use the workaround here
# https://docs.oracle.com/cd/E52668_01/E96266/html/ceph-luminous-issues-27748402.html

class ocf_ceph::osd($disks=[]) {
  require ocf_ceph

  $bootstrap_osd_key = lookup('ceph::bootstrap_osd_key')

  file {
    default:
      owner => 'ceph',
      group => 'ceph';
    '/var/lib/ceph/bootstrap-osd':
      ensure => directory;
    '/var/lib/ceph/bootstrap-osd/ceph.keyring':
      show_diff => false,
      content   => template('ocf_ceph/bootstrap-osd.erb');
  }

  $disks.each |$disk| {
    exec { "prepare-${disk}":
      command => "ceph-volume lvm prepare --data ${disk}",
      unless  => "ceph-volume lvm list ${disk}",
      notify  => Exec['activate-disks'],
    }
  }

  exec { 'activate-disks':
    command     => 'ceph-volume lvm activate --all',
    refreshonly => true,
  }
}
