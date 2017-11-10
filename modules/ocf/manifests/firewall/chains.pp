class ocf::firewall::chains {
  # We put all puppet input/output firewall rules in dedicated chains managed
  # by puppet. This way, puppet will automatically purge rules which get
  # deleted from the manifest.
  firewallchain {
    ['PUPPET-OUTPUT:filter:IPv4', 'PUPPET-OUTPUT:filter:IPv6']:
      ensure => present,
      purge  => true;
  } ->
  ocf::firewall::firewall46 {
    default:
      require => undef;

    '100 run rules in PUPPET-OUTPUT chain':
      opts => {
        chain => 'OUTPUT',
        proto => 'all',
        jump  => 'PUPPET-OUTPUT',
      };
  }

  firewallchain {
    ['PUPPET-INPUT:filter:IPv4', 'PUPPET-INPUT:filter:IPv6']:
      ensure => present,
      purge  => true;
  } ->
  ocf::firewall::firewall46 {
    default:
      require => undef;

    '100 run rules in PUPPET-INPUT chain':
      opts => {
        chain => 'INPUT',
        proto => 'all',
        jump  => 'PUPPET-INPUT',
      };
  }
}
