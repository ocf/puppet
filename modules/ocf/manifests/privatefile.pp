define ocf::privatefile(
  String $path = $title,
  Optional[String] $source = undef,
  Optional[String] $content_path = undef,
  Optional[String] $mode = undef,
  String $owner = 'root',
  String $group = 'root',
  Boolean $force = false,
  Boolean $purge = false,
  Boolean $recurse = false,
  Enum['file', 'directory'] $ensure = 'file',
) {
  if $source and $content_path {
    fail('Both source and content_path parameters cannot be set for an ocf::privatefile resource')
  }

  $opts = {
    path    => $path,
    mode    => $mode,
    owner   => $owner,
    group   => $group,
    force   => $force,
    purge   => $purge,
    recurse => $recurse,
    ensure  => $ensure,
  }

  if $::use_private_share {
    if $content_path {
      # For some reason, puppet-lint thinks the file function call (or
      # $content) are top-scope variables when they are not, so the check is
      # ignored for now.
      $file_opts = $opts + {content => file($content)} # lint:ignore:variable_scope
    } elsif $source {
      $file_opts = $opts + {source => $source}
    }
  } else {
    # Provide a dummy file as a fallback with some pre-defined contents since
    # the private share where the source/content would have come from is not
    # available
    $file_opts = $opts + {content => 'dummy private file'}
  }

  file { $title:
    backup    => false,
    show_diff => false,
    *         => $file_opts,
  }
}
