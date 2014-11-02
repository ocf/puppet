# Generates bundles from certificates and chains in private/ssl.
#
# The primary use is to minimize the amount of manual concatenation we need to
# do, especially since many of our certs use the same chain. We can simply
# use a single cert file and symlink everything else. Our ssl directory can
# then look something like:
#
#   api.asuc.ocf.berkeley.edu.chain -> /etc/ssl/certs/incommon-intermediate.crt
#   api.asuc.ocf.berkeley.edu.key -> biohazard.ocf.berkeley.edu.key
#   api.asuc.ocf.berkeley.edu.crt (individual cert)
#   biohazard.ocf.berkeley.edu.key (master key)
#
# ...and not have to do the manual concatenation.

class ocf_apphost::ssl {
  file {
    '/etc/ssl/apphost':
      ensure  => directory,
      mode    => '0755';

    '/etc/ssl/private/apphost':
      ensure  => directory,
      source  => 'puppet:///private/ssl',
      recurse => true,
      mode    => '0600',
      notify  => Exec['rebuild-ssl-bundles'];

    '/usr/local/sbin/rebuild-ssl-bundles':
      source => 'puppet:///modules/ocf_apphost/rebuild-ssl-bundles',
      mode   => '0755',
      notify => Exec['rebuild-ssl-bundles'];
  }

  exec { 'rebuild-ssl-bundles':
    command     => '/usr/local/sbin/rebuild-ssl-bundles',
    refreshonly => true,
    require     => [
      File['/usr/local/sbin/rebuild-ssl-bundles'],
      File['/etc/ssl/apphost']],
    notify      => Service['nginx'];
  }
}
