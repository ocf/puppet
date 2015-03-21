class ocf_backups::rsnapshot {
  package { 'rsnapshot':; }

  file {
    '/opt/share/backups/rsnapshot.conf':
      source => 'puppet:///modules/ocf_backups/rsnapshot.conf';
  }

  # From the rsnapshot man page:
  #
  #     It is usually a good idea to schedule the larger backup levels to run a
  #     bit before the lower ones.
  #
  # (where "largest" means monthly > weekly > daily)
  #
  # Currently, a job takes about 2 hours, so we leave 4 hours between backup
  # levels. We want to ensure times don't collide. The general plan is:
  #
  #     8pm-12am monthly backup takes place
  #     12am-4am: weekly backup takes place
  #     4am-8am: daily backup takes place
  #     8am+: backups copied from pandemic -> hal
  #           (during the day since it produces no load on the prod. drives)

  $rsnapshot = 'rsnapshot -c /opt/share/backups/rsnapshot.conf'

  Cron {
    user   => root,
    minute => '0',
    month  => '*'
  }

  cron {
    # 8pm on 1st of month
    'rsnapshot-monthly':
      command  => "${rsnapshot} monthly",
      hour     => '20',
      monthday => '1',
      weekday  => '*';

    # 12am Saturday mornings
    'rsnapshot-weekly':
      command  => "${rsnapshot} weekly",
      hour     => '0',
      monthday => '*',
      weekday  => '6';

    # 4am daily
    'rsnapshot-daily':
      command  => "${rsnapshot} sync && ${rsnapshot} daily",
      hour     => '4',
      monthday => '*',
      weekday  => '*';
  }
}
