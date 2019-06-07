# Ceph object store daemon configuration
# Set ocf_ceph::osd::disks to be the disks allocated to ceph
# If you have issues just dd if=/dev/zero the disk and try again

class ocf_ceph::osd($disks=[]) {
  include ocf_ceph

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
