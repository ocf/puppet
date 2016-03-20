class ocf_backups::rsnapshot {
  package { 'rsnapshot':; }

  file {
    '/opt/share/backups/rsnapshot.conf':
      source => 'puppet:///modules/ocf_backups/rsnapshot.conf';

    '/opt/share/backups/check-rsnapshot-backups':
      source => 'puppet:///modules/ocf_backups/check-rsnapshot-backups',
      mode   => '0755';
  }


  # TODO: update times listed here after move to remote backups

  # Since we use sync_first, actual backups only happen at the most frequent
  # ("smallest") backup level, i.e. daily.
  #
  # The other backup levels just promote a daily backup into a weekly/monthly
  # one, so they are comparatively fast.
  #
  # As of 2015-03-29, it takes 30 minutes to do a promotion, and 4 hours to do
  # a full backup. So we leave 2 hours for promotions and 8 hours for a full
  # backup to be safe.
  #
  # It's important that jobs don't overlap, so our plan is:
  #     10pm-12am monthly backup takes place (~30 minutes)
  #     12am-2am: weekly backup takes place (~30 minutes)
  #     2am-10am: daily backup takes place (~4 hours)

  $rsnapshot = 'rsnapshot -c /opt/share/backups/rsnapshot.conf'

  Cron {
    user   => root,
    minute => '0',
  }

  cron {
    # 10pm on 1st of month
    'rsnapshot-monthly':
      command  => "${rsnapshot} monthly",
      hour     => '22',
      monthday => '1';

    # 12am Saturday mornings
    'rsnapshot-weekly':
      command  => "${rsnapshot} weekly",
      hour     => '0',
      weekday  => '6';

    # 2am daily
    'rsnapshot-daily':
      command  => "${rsnapshot} sync && ${rsnapshot} daily",
      hour     => '2';

    # check rsnapshot backups to ensure they're actually happening
    'check-rsnapshot-backups':
      command  => '/opt/share/backups/check-rsnapshot-backups',
      hour     => '10';
  }
}
