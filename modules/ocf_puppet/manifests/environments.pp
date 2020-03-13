class ocf_puppet::environments {
  package { 'r10k':; }

  # Create a Puppet environment for each staffer, if one doesn't already exist.
  #
  # The vcsrepo type sort of works here, but it will reset your git remote and
  # complain if there are issues like un-checked-out git submodules, which we
  # don't use any more, but used to use.
  #
  # Instead, we just call `git clone`.
  if $::ocf_staff {
    $staff = split($::ocf_staff, ',')
    $staff.each |$user| {
      $repo_path = "${::puppet_environmentpath}/${user}"

      # We do the git checkout as the user, so we must ensure the directory exists
      # (and is owned by the user) first, since users can't make directories under
      # the root environments directory.
      file { $repo_path:
        ensure => directory,
        owner  => $user,
        group  => ocf,
      }

      exec { "git clone https://github.com/ocf/puppet ${repo_path}":
        user    => $user,
        unless  => "test -d ${repo_path}/.git",
        require => [File[$repo_path], Package['git'], Package['r10k']];
      }
    }
  }

  # Add some basic config for puppet run as non-root
  # This allows staff to run `puppet generate types --environment <username>`
  # to generate resource types for their own environment.
  file {
    [
      '/etc/skel/.puppetlabs/',
      '/etc/skel/.puppetlabs/etc/',
      '/etc/skel/.puppetlabs/etc/puppet/',
    ]:
      ensure => directory;

    '/etc/skel/.puppetlabs/etc/puppet/puppet.conf':
      content => "codedir = /etc/puppetlabs/code\n";
  }
}
