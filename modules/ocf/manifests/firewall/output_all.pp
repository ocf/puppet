# Firewall rules to allow OUTPUT everywhere
class ocf::firewall::output_all {

  ocf::firewall::firewall46 {
    '899 allow OUTPUT to all destinations':
      opts   => {
        chain  => 'PUPPET-OUTPUT',
        proto  => 'all',
        action => 'accept',
      },
      before => undef,
  }
}
