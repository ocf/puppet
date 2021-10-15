# ftpsync is a Fedora tool for mirroring Fedora archives:
# https://pagure.io/quick-fedora-mirror

define ocf_mirrors::qfm(
    $cron_minute,
    $cron_hour = '*',
    $remote_host = 'rsync://dl.fedoraproject.org',
    $rsync_module = "fedora-${title}",
    $master_module = 'fedora-buffet',
    $mirror_path = '/opt/mirrors/ftp/fedora',
    $project_path = "/opt/mirrors/project/${title}",
    $project_timefile = "/opt/mirrors/project/${title}/last_mirror_time"
  ) {

  file {
    default:
      owner => mirrors,
      group => mirrors;

    [$project_path, "${project_path}/log"]:
      ensure => directory,
      mode   => '0755';

    "${project_path}/quick-fedora-mirror.conf":
      content => template('ocf_mirrors/quick-fedora-mirror.conf.erb'),
      mode    => '0644';
  }

  exec { "get-qfm-${title}":
    command => "sh -c 'git clone https://pagure.io/quick-fedora-mirror.git ${project_path}'",
    user    => 'mirrors',
    require => File[$project_path];
  }

  ocf_mirrors::timer { "fedora-${title}":
    exec_start => "${project_path}/quick-fedora-mirror",
    hour       => $cron_hour,
    minute     => $cron_minute,
    require    => File["${project_path}/log", "${project_path}/quick-fedora-mirror.conf"],
  }
}
