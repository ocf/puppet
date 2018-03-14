class ocf_mirrors::trisquel {
  ocf_mirrors::ftpsync {
    'trisquel':
      rsync_host  => 'rsync.trisquel.info',
      rsync_path  => 'trisquel.packages',
      cron_minute => '45';

    'trisquel-images':
      rsync_host  => 'rsync.trisquel.info',
      rsync_path  => 'trisquel.iso',
      rsync_extra => '--block-size=8192',
      cron_minute => '55';
  }

  ocf_mirrors::monitoring { 'trisquel':
    type          => 'debian',
    dist_to_check => 'flidas',
    upstream_host => 'devel.trisquel.info',
    upstream_path => '/archive/trisquel',
  }
}
