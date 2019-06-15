class ocf::hidepid {

  $group_cap_ptrace = 'capptrace'

  group { $group_cap_ptrace:
    ensure => present,
    name   => $group_cap_ptrace,
    system => true,
    before => Mount['/proc'];
  } ->

  ocf::systemd::override { 'hidepid':
    unit    => 'systemd-logind.service',
    content => "[Service]\nSupplementaryGroups=${group_cap_ptrace}\n",
  }

  # NOTE: When policykit is eventually upgraded to version 0.115 we will need
  # to make a similar change to that unit file.

  mount { '/proc':
    # Remounts proc with hidepid=2. This prevents users from seeing
    # processes that aren't their own using command line tools and
    # by manually going into /proc/<pid>.
    ensure   => mounted,
    remounts => true,
    device   => '/proc',
    fstype   => 'procfs',
    options  => "rw,hidepid=2,gid=${group_cap_ptrace}";
  }
}
