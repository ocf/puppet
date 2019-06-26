# Expands ['mastodon', ('pma', ['phpmyadmin'])]
# to { 'mastodon.ocf.berkeley.edu' => 'mastodon.ocf.io', 'mastodon']
#      'pma.ocf.berkeley.edu       => ['pma.ocf.io', 'pma', 'phpmyadmin.ocf.berkeley.edu',
#                                      'phpmyadmin.ocf.io', 'phymyadmin'] }

function ocf_lb::gen_aliases(Array $services) >> Hash[String, Array[String]] {
  $expanded_services = $services.map |$service| {
    case $service {
      String : {
        ["${service}.ocf.berkeley.edu", [$service, "${service}.ocf.io"]]
      }
      Tuple[String, Array[String]] : {
        $service_name = $service[0]
  $other_aliases = $service[1].map |$alias_name| {
          ["${alias_name}.ocf.berkeley.edu", "${alias_name}.ocf.io", $alias_name]
  }
        $aliases = [$service_name, "${service_name}.ocf.io"] + flatten($other_aliases)

        ["${service_name}.ocf.berkeley.edu", $aliases]
      }

      default: {
        fail('Expected String or Tuple[String, Array[String]]')
      }
    }
  }

  Hash($expanded_services)
}
