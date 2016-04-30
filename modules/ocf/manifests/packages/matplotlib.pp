class ocf::packages::matplotlib {
  $packages = ['python-matplotlib', 'python3-matplotlib']

  package { $packages:; }

  # matplotlib defaults to using the `TkAgg` backend, which doesn't work without
  # an X server installed, even if you only save to files (and don't actually try
  # to display anything).
  #
  # Rather than modify our code, we change the system backend if we don't expect
  # to run an X server.
  #
  # http://stackoverflow.com/a/4706614
  $runs_x_server = tagged('ocf_desktop')
  $backend = $runs_x_server ? {
    false  => 'Agg',
    true   => 'TkAgg',
  }

  exec { "sed -i 's/^backend\s*:.*$/backend : ${backend}/' /etc/matplotlibrc":
    unless => "grep -qE '^backend\s*:\s*${backend}' /etc/matplotlibrc",
    require => Package[$packages];
  }
}
