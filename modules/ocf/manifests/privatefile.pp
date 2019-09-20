# This class exists to abstract out accesses to the puppet private share so
# that octocatalog-diff can generally ignore them and replace the file contents
# with dummy contents. It does not and should not have access to the private
# share, since it could accidentally leak secrets and will show output in
# jenkins logs that are public.
#
# Initially this defined type didn't exist and conditionals using the were used
# around everything that used the private share. This worked ok, but led to
# dependency issues where a resource that would normally exist was then hidden
# behind a conditional and wouldn't be seen by octocatalog-diff. This approach
# is better because it can provide a dummy file and a more consistent
# experience across all uses of the private share.
#
# This also gives a convenient interface to enforce file parameters like
# show_diff and backup that we don't want to be set to true for any private
# resources.
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

  if $::dummy_secrets {
    # Provide a dummy file as a fallback with some pre-defined contents since
    # the private share where the source/content would have come from is not
    # available
    $file_opts = $opts + {content => 'dummy private file'}
  } else {
    if $content_path {
      $file_opts = $opts + {content => file($content_path)}
    } elsif $source {
      $file_opts = $opts + {source => $source}
    }
  }

  file { $title:
    backup    => false,
    show_diff => false,
    *         => $file_opts,
  }
}
