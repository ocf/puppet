class ocf::packages::lvm {
  package { ['lvm2']:; }

  exec {
    # Enable sending discards to the underlying storage layer when space is
    # deallocated.
    #
    # Discards are a feature of TRIM which greatly improves performance for
    # SSDs. This flag only affects discards when commands like lvremove are
    # used to deallocate a chunk of space. It's still necessary to ensure
    # filesystems are properly discarding.
    'lvm.conf: enable discards':
      command => "sed -i 's/issue_discards = 0$/issue_discards = 1/' /etc/lvm/lvm.conf",
      onlyif  => "grep -E 'issue_discards = 0$' /etc/lvm/lvm.conf",
      require => Package['lvm2'];
  }
}
