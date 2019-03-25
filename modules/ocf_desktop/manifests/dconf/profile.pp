# Modified from pupmod-simp-dconf
# (https://github.com/simp/pupmod-simp-dconf/blob/66ba6f224f14211600897faca9dd784fad1b871f/manifests/profile.pp)

type Dconf::Profile = Hash[
  String[1],                                            # The name of the database
  Struct[{
    type  => Enum['user', 'system', 'service', 'file'], # The type of database
    order => Integer[1],                                # The order of the entry in the list
  }],
]

define ocf_desktop::dconf::profile (
  Dconf::Profile       $entries,
  String[1]            $target = $name,
  Stdlib::AbsolutePath $base_dir = '/etc/dconf/profile',
) {

  include 'ocf_desktop::dconf'

  ensure_resource('file', $base_dir, {
    ensure => directory,
    owner  => root,
    group  => root,
    mode   => '0644',
  })

  concat { "${base_dir}/${target}":
    ensure => present,
    order  => numeric,
  }

  $entries.each |String[1] $db_name, Hash $attrs| {
    concat::fragment { "dconf/${target}/${db_name}":
      target  => "${base_dir}/${target}",
      content => "${attrs['type']}-db:${db_name}\n",
      order   => $attrs['order']
    }
  }
}
