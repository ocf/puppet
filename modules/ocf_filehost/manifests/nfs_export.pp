define ocf_filehost::nfs_export (
  # allow specifying an export point that is different from the title; useful
  # for exports where you want to specify different options for different
  # groups of hosts that all share the same export point.
  #
  # a map is used so that each groups of hosts with the same export point are
  # listed in the file as under the same export point:
  #   /path/to/dir \
  #     host1(opts) \
  #     host2(opts) \
  # instead of:
  #   /path/to/dir \
  #     host1(opts) \
  #   /path/to/dir \
  #     host2(opts) \

  Array[Struct[{
    options => Array[String],
    hosts => Array[String],
  }]] $clients,
) {

  $export_chunks = $clients.map |$client| {
    $option_string = join($client['options'], ',');
    $hosts_plus_option = $client['hosts'].map |$host| { "    ${host}(${option_string})" };
    join($hosts_plus_option, " \\\n")
  }

  $export_string = join($export_chunks, " \\\n");

  concat::fragment { "nfs-export-${title}":
    target  => '/etc/exports',
    content => "${title} \\\n${export_string}\n\n"
  }
}
