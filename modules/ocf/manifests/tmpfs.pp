# Mount /tmp as a tmpfs
class ocf::tmpfs {
  mount { '/tmp':
    device  => 'tmpfs',
    fstype  => 'tmpfs',
    options => 'noatime,nodev,nosuid';
  }
}
