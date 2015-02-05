# TODO: command is not escaped in any way; if it contains newlines or other weird characters, it will break
define ocf::webhook($service, $command, $secretfile, $path = $title, $owner = 'root', $group = 'root') {
  if $service != 'github' {
    fail('Only the "github" webhook service is defined.')
  }

  file { $path:
    content => template('ocf/webhook.cgi.erb'),
    owner   => $owner,
    group   => $group,
    mode    => '0755';
  }

  ensure_resource('file', '/opt/share/webhook', {
      ensure  => directory,
      source  => 'puppet:///modules/ocf/webhook',
      recurse => true,
      mode    => '0755'
    }
  )
}
