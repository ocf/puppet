# Things for helping with offsite backups.
class ocf_backups::offsite {
  package { ['lftp', 'python3-pycurl']:; }

  file {
    '/opt/share/backups/create-encrypted-backup':
      source => 'puppet:///modules/ocf_backups/create-encrypted-backup',
      mode   => '0755';

    '/opt/share/backups/upload-to-box':
      source => 'puppet:///modules/ocf_backups/upload-to-box',
      mode   => '0755';

    '/opt/share/backups/prune-old-backups':
      source => 'puppet:///modules/ocf_backups/prune-old-backups',
      mode   => '0755';

    '/opt/share/backups/keys':
      ensure  => directory,
      source  => 'puppet:///modules/ocf_backups/keys',
      recurse => true;

    # Box.com credentials and API id/secret
    '/opt/share/backups/box-creds.json':
      content   => template('ocf_backups/box-creds.json.erb'),
      mode      => '0600',
      show_diff => false;
  }

  # Runs Saturday at noon, makes a backup and then uploads it to Box.com
  cron {
    'encrypt-and-backup':
      command => '/opt/share/backups/create-encrypted-backup && chronic /opt/share/backups/upload-to-box',
      user    => root,
      weekday => '6',
      hour    => '12',
      minute  => '0';

    'prune-old-backups':
      command => 'chronic /opt/share/backups/prune-old-backups',
      user    => root,
      hour    => '0',
      minute  => '0';
  }
}
