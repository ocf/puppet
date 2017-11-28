class ocf_staffvm::firewall {
  ocf::firewall::firewall46 { '100 allow all incoming traffic':
    opts => {
      chain  => 'PUPPET-INPUT',
      proto  => 'all',
      action => 'accept',
    }
  }
}
