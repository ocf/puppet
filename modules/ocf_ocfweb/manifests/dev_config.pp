# Provides /etc/ocfweb/ocfweb.conf for development.
# This contains suitable settings for local dev and can be used on supernova,
# staff VMs, etc.
class ocf_ocfweb::dev_config($group = 'ocfstaff') {
  include ocf::firewall::output_printers

  # TODO: stop copy-pasting this password validation everywhere
  $redis_password = assert_type(Pattern[/^[a-zA-Z0-9]*$/], hiera('create::redis::password'))
  $ocfmail_password = assert_type(Pattern[/^[a-zA-Z0-9]*$/], hiera('ocfmail::mysql::dev_password'))
  $ocfstats_password = assert_type(Pattern[/^[a-zA-Z0-9]*$/], hiera('ocfstats::mysql::dev_password'))

  $broker = "redis://:${redis_password}@admin.ocf.berkeley.edu:6378"
  $backend = $broker


  # libcrack2-dev is a dependency of the crypto libraries that
  # ocfweb depends on, but we can't just declare the package
  # because it conflicts with extrapackages, which is declared in
  # ocf_admin along with this manifest (for supernova)
  ensure_packages(['libcrack2-dev'])

  file {
    '/etc/ocfweb':
      ensure    => directory;

    '/etc/ocfweb/ocfweb.conf':
      content   => template('ocf_ocfweb/dev_config.conf.erb'),
      group     => $group,
      mode      => '0640',
      show_diff => false;
  }
}
