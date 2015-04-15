# TODO: command is not escaped in any way; if it contains newlines or other weird characters, it will break
define ocf::webhook($service, $command, $secretsource, $path = $title,
                    $owner = 'root', $group = 'root', $secretowner = 'root', $secretgroup = 'www-data') {
  if $service != 'github' {
    fail('Only the "github" webhook service is defined.')
  }

  # generate a unique name for the secret
  $uid = sha1($name)
  $secretpath = "/opt/share/webhook/secrets/${uid}.secret"

  file { $secretpath:
    source  => $secretsource,
    owner   => $secretowner,
    group   => $secretgroup,
    mode    => '0640';
  }

  file { $path:
    content => template('ocf/webhook.cgi.erb'),
    owner   => $owner,
    group   => $group,
    mode    => '0755';
  }

  ensure_resource('file', '/opt/share/webhook', {
      ensure  => directory,
      mode    => '0755'
    }
  )

  ensure_resource('file', '/opt/share/webhook/services', {
      ensure  => directory,
      source  => 'puppet:///modules/ocf/webhook',
      recurse => true,
      mode    => '0755'
    }
  )

  ensure_resource('file', '/opt/share/webhook/secrets', {
      ensure  => directory,
      mode    => '0755'
    }
  )
}
