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

  # Install some packages for generating puppet diffs
  # TODO: Move this somewhere else alongside the puppet certs added below
  package { ['octocatalog-diff', 'puppetdb-termini']:; }

  file {
    '/etc/ocfweb':
      ensure    => directory;

    '/etc/ocfweb/ocfweb.conf':
      content   => template('ocf_ocfweb/dev_config.conf.erb'),
      group     => $group,
      mode      => '0640',
      show_diff => false;
  }

  ocf::privatefile { '/etc/ocfweb/puppet-certs':
    ensure  => 'directory',
    source  => 'puppet:///private-docker/ocfweb/puppet-certs',
    recurse => true,
    purge   => true;
  }
}
