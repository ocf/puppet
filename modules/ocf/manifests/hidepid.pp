class ocf::hidepid {
  mount { '/proc':
    # Remounts proc with hidepid=2. This prevents users from seeing
    # processes that aren't their own using command line tools and
    # by manually going into /proc/<pid>.
    ensure   => mounted,
    remounts => true,
    device   => '/proc',
    fstype   => 'procfs',
    options  => 'remount,rw,hidepid=2',
  }
}
