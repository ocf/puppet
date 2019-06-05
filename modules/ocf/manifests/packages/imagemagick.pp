class ocf::packages::imagemagick {
  package { ['imagemagick']:; }

  # Allows rasterizing filter to handle more complex
  # PDFs without running out of memory
  augeas { 'Increase ImageMagick maximum memory':
    incl    => '/etc/ImageMagick-6/policy.xml',
    lens    => 'Xml.lns',
    context => '/files/etc/ImageMagick-6/policy.xml',
    changes => [
      'set policymap/policy[1]/#attribute/value 1GiB'
    ],
    require => Package['imagemagick'];
  }
}
