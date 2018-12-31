define ocf_filehost::nfs_export (
  Array[String] $options,
  Array[String] $hosts,
) {

  $option_string = join($options, ',');
  $hosts_plus_option = $hosts.map |$host| { "    ${host}(${option_string})" };
  $export_string = join($hosts_plus_option, " \\\n");

  concat::fragment { "nfs-export-${name}":
    target  => '/etc/exports',
    content => "${name} \\\n${export_string}\n\n"
  }
}
