define ocf::privatefile(
  String $path = $title,
  Optional[String] $source  = undef,
  Optional[String] $content = undef,
  Optional[String] $mode    = undef,
  String $owner    = 'root',
  String $group    = 'root',
  Boolean $force   = false,
  Boolean $purge   = false,
  Boolean $recurse = false,
) {
  if $source and $content {
    fail('Both source and content parameters cannot be set for a file resource')
  }

  $opts = {
    path    => $path,
    mode    => $mode,
    owner   => $owner,
    group   => $group,
    force   => $force,
    purge   => $purge,
    recurse => $recurse,
  }

  if $::use_private_share {
    if $content {
      $file_opts = $opts + {content => $content}
    } elsif $source {
      $file_opts = $opts + {source => $source}
    }
  } else {
    # Provide a dummy file as a fallback with some pre-defined contents
    $file_opts = ($opts - [source, content]) + {content => 'dummy private file'}
  }

  file { $title:
    backup    => false,
    show_diff => false,
    *         => $file_opts,
  }
}
