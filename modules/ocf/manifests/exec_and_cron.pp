define ocf::exec_and_cron(
    $command,
    $creates,
    $cron_options = {},
) {
  exec { "${title}-initial":
    command => $command,
    creates => $creates,
  } ->
  cron { $title:
    command => $command,
    *       => $cron_options;
  }
}
