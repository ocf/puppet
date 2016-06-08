# Create a Puppet environment for the user, if one doesn't already exist.
#
# The vcsrepo type sort of works here, but it will reset your git remote and
# complain if there are issues like un-checked-out git submodules, which we
# don't use any more, but used to use.
#
# Instead, we just call `git clone`.
define ocf_puppet::environments::environment($user = $title) {
  $repo_path = "/opt/puppet/env/${user}"

  # We do the git checkout as the user, so we must ensure the directory exists
  # (and is owned by the user) first, since users can't make directories under
  # the /opt/puppet/env directory.
  file { $repo_path:
    ensure => directory,
    owner  => $user,
    group  => ocf,
  }

  exec { "git clone https://github.com/ocf/puppet ${repo_path} && cd ${repo_path} && make vendor":
    user    => $user,
    unless  => "test -d ${repo_path}/.git",
    require => [File[$repo_path], Package['git'], Package['r10k']];
  }
}
