class ocf::firewall::output_printers {
  # Allow output to printers
  firewall_multi { '899 allow output (printers)':
    chain       => 'PUPPET-OUTPUT',
    destination => ['papercut', 'pagefault', 'logjam'],
    proto       => 'all',
    action      => 'accept',
  }
}
