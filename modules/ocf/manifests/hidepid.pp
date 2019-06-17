class ocf::hidepid {

  $group_cap_ptrace = 'capptrace'

  group { $group_cap_ptrace:
    ensure => present,
    name   => $group_cap_ptrace,
    system => true,
    before => Mount['/proc'];
  }

  # systemd-logind and policykit need to access info about all processes.
  # see here: https://wiki.debian.org/Hardening#Mounting_.2Fproc_with_hidepid
  ocf::systemd::override { 'hidepid-logind':
    unit    => 'systemd-logind.service',
    content => "[Service]\nSupplementaryGroups=${group_cap_ptrace}\n",
    require => Group[$group_cap_ptrace];
  }

  if str2bool($::polkit_priv_drop) {
    # Futureproof for policykit for version 0.115. policykit will create this
    # user, we just need to add it to capptrace
    user { 'polkitd':
      name    => 'polkitd',
      groups  => $group_cap_ptrace,
      system  => true,
      require => Group[$group_cap_ptrace];
    }
  }

  mount { '/proc':
    # Remounts proc with hidepid=2. This prevents users from seeing
    # processes that aren't their own using command line tools and
    # by manually going into /proc/<pid>.
    ensure   => mounted,
    remounts => true,
    device   => '/proc',
    fstype   => 'procfs',
    options  => "rw,hidepid=2,gid=${group_cap_ptrace},gid=ocfstaff",
    require  => Group[$group_cap_ptrace];
  }
}
