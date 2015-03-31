class ocf_backups::rsnapshot {
  package { 'rsnapshot':; }

  file {
    '/opt/share/backups/rsnapshot.conf':
      source => 'puppet:///modules/ocf_backups/rsnapshot.conf';

    '/opt/share/backups/copy-backups':
      source => 'puppet:///modules/ocf_backups/copy-backups',
      mode   => '0755';
  }

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
  #     10am+: backups copied from pandemic -> hal
  #           (during the day since it produces no load on the prod. drives)

  $rsnapshot = 'rsnapshot -c /opt/share/backups/rsnapshot.conf'

  Cron {
    user   => root,
    minute => '0',
    month  => '*'
  }

  cron {
    # 10pm on 1st of month
    'rsnapshot-monthly':
      command  => "${rsnapshot} monthly",
      hour     => '22',
      monthday => '1',
      weekday  => '*';

    # 12am Saturday mornings
    'rsnapshot-weekly':
      command  => "${rsnapshot} weekly",
      hour     => '0',
      monthday => '*',
      weekday  => '6';

    # 2am daily
    'rsnapshot-daily':
      command  => "${rsnapshot} sync && ${rsnapshot} daily",
      hour     => '2',
      monthday => '*',
      weekday  => '*';

    # 10am daily
    'copy-backups':
      command  => '/opt/share/backups/copy-backups',
      hour     => '10',
      monthday => '*',
      weekday  => '*';
  }
}
