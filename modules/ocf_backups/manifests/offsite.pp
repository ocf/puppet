# Things for helping with offsite backups.
class ocf_backups::offsite {
  package { ['google-gsutil']:; }

  file {
    '/opt/share/backups/create-encrypted-backup':
      source => 'puppet:///modules/ocf_backups/create-encrypted-backup',
      mode   => '0755';

    '/opt/share/backups/upload-to-google':
      source => 'puppet:///modules/ocf_backups/upload-to-google',
      mode   => '0755';

    '/opt/share/backups/keys':
      ensure  => directory,
      source  => 'puppet:///modules/ocf_backups/keys',
      recurse => true;

    '/opt/share/backups/boto.cfg':
      source => 'puppet:///private/boto.cfg',
      mode   => '0600';
  }
}
