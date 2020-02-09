# Ceph libvirt class, allows libvirt to use Ceph storage
class ocf_ceph::libvirt {
  include ocf_ceph
  include ocf_ceph::admin

  $libvirt_perms = "mon 'profile rbd' osd 'profile rbd pool=vm'"
  $libvirt_keyring_file = '/etc/ceph/libvirt.key'
  $ceph_mons = lookup('ceph::mons')

  package { 'libvirt-daemon-driver-storage-rbd':; }
  package { 'qemu-block-extra':; }

  file { '/etc/ceph/libvirt-secret.xml':
    source => 'puppet:///modules/ocf_ceph/libvirt-secret.xml',
    mode   => '0755',
  }

  # Create a ceph key for libvirt, and give it rbd permissions in the 'vm' pool
  # Then create a libvirt secret from the ceph key
  exec { 'make-libvirt-key':
    command => "ceph auth add client.libvirt ${libvirt_perms}",
    unless  => 'ceph auth get client.libvirt',
  } ->
  file { '/usr/local/bin/mk-libvirt-secret.sh':
    source  => 'puppet:///modules/ocf_ceph/mk-libvirt-secret.sh',
    mode    => '0755',
    require => File['/etc/ceph/libvirt-secret.xml'],
  }

  # We have to run puppet two times on a libvirt bootstrap, once to generate the libvirt secret
  # The fact libvirt_secret_uuid will be set next run, allowing us to use it in libvirt-pool.xml
  if $::libvirt_secret_uuid != undef {
    $libvirt_secret_uuid = $::libvirt_secret_uuid

    file { '/etc/ceph/libvirt-pool.xml':
      content   => template('ocf_ceph/libvirt-pool.xml.erb'),
      mode      => '0600',
      show_diff => false,
      require   => Service["ceph-mon@${::hostname}"],
    } ~>
    exec { 'define-libvirt-pool':
      command     => 'virsh pool-define /etc/ceph/libvirt-pool.xml',
      refreshonly => true,
      require     => Package['libvirt-daemon-driver-storage-rbd'],
    } ~>
    exec { 'start-and-enable-libvirt-pool':
      command     => 'virsh pool-start vm; virsh pool-autostart vm',
      refreshonly => true,
    }
  } else {
    exec { 'make-libvirt-secret':
      command => 'mk-libvirt-secret.sh',
    }

    notify { 'libvirt-repuppet':
      message => 'Created libvirt secret, rerun puppet to create libvirt pool',
    }
  }
}
