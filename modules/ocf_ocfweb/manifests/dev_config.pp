# Provides /etc/ocfweb/ocfweb.conf for development.
# This contains suitable settings for local dev and can be used on supernova,
# staff VMs, etc.
class ocf_ocfweb::dev_config($group = 'ocfstaff') {
  # TODO: stop copy-pasting this everywhere
  $redis_password = file('/opt/puppet/shares/private/create/redis-password')
  validate_re($redis_password, '^[a-zA-Z0-9]*$', 'Bad Redis password')
  $ocfmail_password = file('/opt/puppet/shares/private/ocfweb/ocfmail-dev-password')
  validate_re($ocfmail_password, '^[a-zA-Z0-9]*$', 'Bad ocfmail password')

  $broker = "redis://:${redis_password}@admin.ocf.berkeley.edu:6378"
  $backend = $broker

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
