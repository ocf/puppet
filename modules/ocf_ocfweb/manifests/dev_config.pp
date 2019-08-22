# Provides /etc/ocfweb/ocfweb.conf for development.
# This contains suitable settings for local dev and can be used on supernova,
# staff VMs, etc.
class ocf_ocfweb::dev_config($group = 'ocfstaff') {
  include ocf::firewall::output_printers

  # TODO: stop copy-pasting this password validation everywhere
  $redis_password = assert_type(Pattern[/^[a-zA-Z0-9]*$/], lookup('create::redis::password'))
  $ocfmail_password = assert_type(Pattern[/^[a-zA-Z0-9]*$/], lookup('ocfmail::mysql::dev_password'))
  $ocfstats_password = assert_type(Pattern[/^[a-zA-Z0-9]*$/], lookup('ocfstats::mysql::dev_password'))

  $broker = "redis://:${redis_password}@admin.ocf.berkeley.edu:6378"
  $backend = $broker
  $redis_uri = "rediss://:${redis_password}@admin.ocf.berkeley.edu:6378/1"


  # libcrack2-dev is a dependency of the crypto libraries that
  # ocfweb depends on, but we can't just declare the package
  # because it conflicts with extrapackages, which is declared in
  # ocf_admin along with this manifest (for supernova)
  ensure_packages(['libcrack2-dev'])

  # Install some packages for generating puppet diffs
  # TODO: Move this somewhere else alongside the puppet certs added below
  package {
    'octocatalog-diff':;

    # Newer puppetdb-termini versions (6.5.0-1stretch for instance) have an
    # issue with CRLs
    'puppetdb-termini':
      ensure => '6.4.0-1stretch';
  }

  file {
    '/etc/ocfweb':
      ensure    => directory;

    '/etc/ocfweb/ocfweb.conf':
      content   => template('ocf_ocfweb/dev_config.conf.erb'),
      group     => $group,
      mode      => '0640',
      show_diff => false;
  }

  if $::use_private_share {
    file { '/etc/ocfweb/puppet-certs':
      ensure    => 'directory',
      source    => 'puppet:///private-docker/ocfweb/puppet-certs',
      recurse   => true,
      purge     => true,
      show_diff => false;
    }
  }
}
