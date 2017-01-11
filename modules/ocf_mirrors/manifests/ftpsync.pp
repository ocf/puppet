# ftpsync is a Debian tool for reliably mirroring Debian archives:
# https://www.debian.org/mirror/ftpmirror
define ocf_mirrors::ftpsync(
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

    [$project_path, "${project_path}/log", "${project_path}/etc"]:
      ensure  => directory,
      mode    => '0755';

    "${project_path}/bin":
      ensure  => link,
      target  => "${project_path}/distrib/bin";

    "${project_path}/etc/common":
      ensure  => link,
      target  => "${project_path}/distrib/etc/common";

    "${project_path}/etc/ftpsync.conf":
      content => template('ocf_mirrors/ftpsync.conf.erb'),
      mode    => '0644';
  }

  exec { "get-ftpsync-${title}":
    command => "sh -c 'tmp=$(mktemp) && wget -O \$tmp -q https://ftp-master.debian.org/ftpsync.tar.gz && tar xvfz \$tmp -C ${project_path}'",
    user    => 'mirrors',
    creates => "${project_path}/distrib",
    require => File[$project_path];
  }

  cron { "ftpsync-${title}":
    command => "BASEDIR=${project_path} ${project_path}/bin/ftpsync > /dev/null 2>&1",
    user    => 'mirrors',
    minute  => $cron_minute,
    hour    => $cron_hour,
    require => File["${project_path}/bin", "${project_path}/etc/ftpsync.conf"];
  }
}
