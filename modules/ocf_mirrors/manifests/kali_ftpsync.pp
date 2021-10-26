# Kali has a custom version of the ftpsync tool
# https://www.kali.org/docs/community/setting-up-a-kali-linux-mirror/

define ocf_mirrors::kali_ftpsync(
    $rsync_host,
    $cron_minute,
    $cron_hour = '*',
    $rsync_path = $title,
    $rsync_user = '',
    $rsync_password = '',
    $rsync_extra = '',
    $mirror_name = 'mirrors.ocf.berkeley.edu',
    $mirror_path = "/opt/mirrors/ftp/${title}",
    $project_path = "/opt/mirrors/project/${title}",
  ) {

  file {
    default:
      owner => mirrors,
      group => mirrors;

    $project_path:
      ensure => directory,
      mode   => '0755';

    "${project_path}/etc/ftpsync.conf":
      content => template('ocf_mirrors/ftpsync.conf.erb'),
      mode    => '0644';
  }

  exec { "get-ftpsync-${title}":
    command => "sh -c 'tmp=$(mktemp) && wget -O \$tmp -q https://archive.kali.org/ftpsync.tar.gz && tar xvfz \$tmp -C ${project_path}'",
    user    => 'mirrors',
    creates => ["${project_path}/etc", "${project_path}/log", "${project_path}/bin"],
    require => File[$project_path];
  }

  ocf_mirrors::timer { "ftpsync-${title}":
    exec_start   => "${project_path}/bin/ftpsync",
    environments => { 'BASEDIR' => $project_path },
    hour         => $cron_hour,
    minute       => $cron_minute,
    require      => File["${project_path}/bin", "${project_path}/etc/ftpsync.conf"],
  }
}
