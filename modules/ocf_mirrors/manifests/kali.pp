class ocf_mirrors::kali {
  # TODO: set up as official mirror, sync from archive.kali.org with
  # push-triggered mirroring
  # http://docs.kali.org/community/kali-linux-mirrors
  ocf_mirrors::ftpsync {
    'kali':
      rsync_host               => 'kali.localmsp.org',
      cron_minute              => '15';

    'kali-security':
      rsync_host               => 'kali.localmsp.org',
      cron_minute              => '25';

    'kali-images':
      rsync_host               => 'kali.localmsp.org',
      rsync_path               => 'kali-images',
      rsync_extra              => '--block-size=8192',
      cron_minute              => '35';
  }
}
