class ocf::hidepid {

  # only one group can be authorized to have full procfs access with hidepid=2,
  # so we will reuse ocfstaff for everything else that needs it
  # TODO: look into having a dedicated group that somehow has membership synced
  # with ocfstaff?
  $procfs_authorized_group = 'ocfstaff'

  # systemd-logind and policykit need to access info about all processes.
  # see here: https://wiki.debian.org/Hardening#Mounting_.2Fproc_with_hidepid
  ocf::systemd::override { 'hidepid-logind':
    unit    => 'systemd-logind.service',
    content => "[Service]\nSupplementaryGroups=${procfs_authorized_group}\n",
  }

  if str2bool($::polkit_priv_drop) {
    # Futureproof for policykit for version 0.115. policykit will create this
    # user, we just need to add it to the authorized group
    user { 'polkitd':
      name   => 'polkitd',
      groups => $procfs_authorized_group,
      system => true,
    }
  }

  # user@.service needs this too: https://github.com/systemd/systemd/issues/12955
  ocf::systemd::override { 'hidepid-user-service':
    unit    => 'user@.service',
    content => "[Service]\nSupplementaryGroups=${procfs_authorized_group}\n",
  }

  mount { '/proc':
    # Remounts proc with hidepid=2. This prevents users from seeing
    # processes that aren't their own using command line tools and
    # by manually going into /proc/<pid>.
    ensure   => mounted,
    remounts => true,
    device   => '/proc',
    fstype   => 'procfs',
    options  => "rw,hidepid=2,gid=${procfs_authorized_group}",
  }
}
