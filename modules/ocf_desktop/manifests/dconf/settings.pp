# Modified from pupmod-simp-dconf
# (https://github.com/simp/pupmod-simp-dconf/blob/8a4e9b047ddfe1092682fff7f7d3b48b23605631/manifests/settings.pp)

type Dconf::SettingsHash = Hash[
  String[1],
  Hash[
    String[1],
    Struct[{
      value => NotUndef,
      lock  => Optional[Boolean], # defaults to true
    }],
  ],
]

define ocf_desktop::dconf::settings (
  Dconf::SettingsHash      $settings_hash,
  String[1]                $profile,
  Enum['present','absent'] $ensure = 'present',
  Stdlib::AbsolutePath     $base_dir = '/etc/dconf/db',
) {

  include 'ocf_desktop::dconf'

  ensure_resource('file', $base_dir, {
    ensure  => directory,
    owner   => root,
    group   => root,
    mode    => '0644',
  })

  $_name = regsubst($name.downcase, '( |/|!|@|#|\$|%|\^|&|\*|[|])', '_', 'G')

  $_profile_dir = "${base_dir}/${profile}.d"
  $_target = "${_profile_dir}/${_name}"

  file { $_profile_dir:
    ensure  => directory,
    owner   => root,
    group   => root,
    mode    => '0644',
    recurse => true,
    purge   => true,
  }

  file { $_target:
    ensure => file,
    owner  => root,
    group  => root,
    mode   => '0644',
  }

  $_lock_content = ''
  $settings_hash.map |$_schema, $_settings| {

    $_settings.keys.each |$_key| {
      ini_setting { "${_target} [${_schema}] $_key":
        ensure  => 'present',
        path    => $_target,
        section => $_schema,
        setting => $_key,
        value   => $_settings[$_key]['value'],
        notify  => Exec["dconf update ${name}"]
      }
    }

    $_settings.map |$_item, $_setting| {
      if $_setting['lock'] != false {
        $_lock_content = "${_lock_content}/${$_schema}/${_item}\n"
      }
    }
  }

  if $_lock_content == '' {
    file { "${_profile_dir}/locks/${_name}":
      ensure => absent
    }
  }
  else {
    file { "${_profile_dir}/locks":
      ensure  => directory,
      owner   => root,
      group   => root,
      mode    => '0640',
      recurse => true,
      purge   => true
    }

    file { "${_profile_dir}/locks/${_name}":
      ensure  => file,
      owner   => root,
      group   => root,
      mode    => '0640',
      content => $_lock_content,
      notify  => Exec["dconf update ${name}"]
    }
  }

  # `dconf update` doesn't return anything besides 0, so we have to figure out
  # if it was successful
  exec { "dconf update ${name}":
    command     => "bash -c 'dconf update |& tee /dev/fd/2 | wc -c | grep ^0$'",
    logoutput   => true,
    umask       => '0033',
    refreshonly => true
  }
}
