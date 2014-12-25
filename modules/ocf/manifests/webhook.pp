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
}
