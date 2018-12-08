class ocf_kubernetes::master::loadbalancer::ssl(
  $server_name,
) {

  $cnames = ldap_attr_multi($server_name, 'dnsCname')

  $cnames.each |String $alias| {
    $service_fqdn = "${alias}.ocf.berkeley.edu"
    ocf::ssl::bundle { $service_fqdn:
      domains => [$service_fqdn, "${alias}.ocf.io"],
    }
  }

  file { '/etc/ssl/ocf-certs.txt':
    mode    => '0400',
    owner   => 'haproxy',
    group   => 'haproxy',
    content => template('ocf_kubernetes/master/loadbalancer/ssl/ocf-certs.txt.erb'),
  }
}
