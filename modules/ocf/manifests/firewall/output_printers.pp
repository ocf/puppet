class ocf::firewall::output_printers {
  # Allow output to printers
  ['papercut', 'pagefault'].each |$printer| {
    firewall { "899 allow output to ${printer}":
      chain       => 'PUPPET-OUTPUT',
      destination => $printer,
      proto       => 'all',
      action      => 'accept',
    }
  }
}
