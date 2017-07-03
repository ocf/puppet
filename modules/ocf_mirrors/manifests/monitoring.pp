define ocf_mirrors::monitoring(
    $type = 'ftpsync',
    $project_path = "/opt/mirrors/project/${title}",
    $upstream_host = undef,
    $dist_to_check = undef,
    $local_path = "/${title}",
    $upstream_path = "/${title}",
    $upstream_protocol = 'http',
    $ensure = 'present',
  ) {

  if $ensure == 'present' {
    file { "${project_path}/health":
      content => template("ocf_mirrors/monitoring/${type}-health.erb"),
      mode    => '0755';
    }

    cron { "${title}-health":
      command => "${project_path}/health",
      user    => 'mirrors',
      hour    => '*/6',
      minute  => '0';
    }
  } else {
    file { "${project_path}/health":
      ensure => absent;
    }

    cron { "${title}-health":
      ensure => absent;
    }
  }
}
