# Install megacli and status-reporting cronjob.
# To be used on physical servers with LSI RAID cards.
class ocf::megacli {
  package { ['sysfsutils', 'libsysfs2']:; }

  # Steps for getting an extracted copy of megacli:
  #   1. Download from LSI website, unzip the zip.
  #   2. Use `alien --to-tgz *.rpm` to convert the RPM to a tarball.
  #   3. Extract the tarball
  #   4. mv opt/MegaRAID/MegaCli/MegaCli .
  file {
    '/usr/local/sbin/megacli':
      source => 'puppet:///contrib/common/megacli/MegaCli64',
      mode   => '0755';
    '/usr/share/doc/megacli':
      ensure => directory;
    '/usr/share/doc/megacli/readme':
      source => 'puppet:///contrib/common/megacli/MegaCLI.txt';
    '/usr/share/doc/megacli/ocf-readme':
      source => 'puppet:///modules/ocf/megacli/ocf-readme';
    '/usr/local/sbin/megacli-cron':
      source => 'puppet:///modules/ocf/megacli/megacli-cron',
      mode   => '0755';
    '/lib/x86_64-linux-gnu/libsysfs.so.2.0.2':
      ensure => link,
      target => '/lib/x86_64-linux-gnu/libsysfs.so.2';
  }

  cron { 'megacli-cron':
    command => '/usr/local/sbin/megacli-cron',
    minute  => '*/5',
    require => [
      File[
        '/usr/local/sbin/megacli',
        '/usr/local/sbin/megacli-cron',
        '/lib/x86_64-linux-gnu/libsysfs.so.2.0.2'
      ],
      Package['sysfsutils'],
    ];
  }
}
