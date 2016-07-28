# Things for helping with offsite backups.
class ocf_backups::offsite {
  package {
    [
      'google-gsutil',
      'python3-pycurl'
    ]:;
  }

  file {
    '/opt/share/backups/create-encrypted-backup':
      source => 'puppet:///modules/ocf_backups/create-encrypted-backup',
      mode   => '0755';

    '/opt/share/backups/upload-to-google':
      source => 'puppet:///modules/ocf_backups/upload-to-google',
      mode   => '0755';

    '/opt/share/backups/upload-to-box':
      source => 'puppet:///modules/ocf_backups/upload-to-box',
      mode   => '0755';

    '/opt/share/backups/keys':
      ensure  => directory,
      source  => 'puppet:///modules/ocf_backups/keys',
      recurse => true;

    '/opt/share/backups/boto.cfg':
      source => 'puppet:///private/boto.cfg',
      mode   => '0600';

    # Box.com credentials and API id/secret
    '/opt/share/backups/box-creds.json':
      source => 'puppet:///private/box-creds.json',
      mode   => '0600';

    # This changes each time a backup is made, so it is not stored on the
    # puppetmaster and instead is just a local file on the backups server.
    '/opt/share/backups/box-refresh-token':
      mode => '0600';
  }

  # Runs Saturday at noon, makes a backup and then uploads it to Box.com
  cron {
    'encrypt-and-backup':
      command => '/opt/share/backups/create-encrypted-backup && /opt/share/backups/upload-to-box -q',
      user    => root,
      weekday => '6',
      hour    => '12',
      minute  => '0';
  }
}
