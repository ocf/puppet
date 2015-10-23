# Automatically trim filesystems daily.
#
# This helps greatly increase write performance on our SSDs.
class ocf::fstrim {
  package { 'util-linux':; }

  cron { 'fstrim':
    command => '/sbin/fstrim -a',
    user    => root,
    special => 'daily';
  }
}
