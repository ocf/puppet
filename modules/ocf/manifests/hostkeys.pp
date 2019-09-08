class ocf::hostkeys {
  ocf::privatefile {
    '/etc/ssh/ssh_host_dsa_key':
      mode   => '0600',
      source => 'puppet:///private/hostkeys/ssh_host_dsa_key';
    '/etc/ssh/ssh_host_dsa_key.pub':
      mode   => '0644',
      source => 'puppet:///private/hostkeys/ssh_host_dsa_key.pub';
    '/etc/ssh/ssh_host_rsa_key':
      mode   => '0600',
      source => 'puppet:///private/hostkeys/ssh_host_rsa_key';
    '/etc/ssh/ssh_host_rsa_key.pub':
      mode   => '0644',
      source => 'puppet:///private/hostkeys/ssh_host_rsa_key.pub';
    '/etc/ssh/ssh_host_ecdsa_key':
      mode   => '0600',
      source => 'puppet:///private/hostkeys/ssh_host_ecdsa_key';
    '/etc/ssh/ssh_host_ecdsa_key.pub':
      mode   => '0644',
      source => 'puppet:///private/hostkeys/ssh_host_ecdsa_key.pub';
  }
}
