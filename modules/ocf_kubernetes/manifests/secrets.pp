class ocf_kubernetes::secrets {
  # The way we manage secrets in Kubernetes is that we put them in the Puppet
  # private share under "docker", which is made available to the Kubernetes
  # workers via a special file share, "private-docker".
  #
  # We then mount individual directories (e.g. for the RT service, we might
  # mount /opt/share/docker/secrets/rt into the container).
  #
  # Since inside the container, our processes typically run as "nobody" (or
  # another unprivileged user), these secrets need to be world-readable.
  # That's fine inside Docker, but outside Docker, we don't want random users
  # on the host to be able to access them. So we make one directory,
  # `/opt/share/docker`, which has strict permissions, and then put the secrets
  # in `/opt/share/docker/secrets` underneath it.
  #
  # The extra directory is theoretically unnecessary, but in practice Puppet
  # makes it hard to set "0700" on a directory, while recursively setting
  # 0644/0755 on children. Oh well.
  #
  # Only some Kubernetes workers have this class. Some (e.g. desktops) don't,
  # and so won't run jobs that require secrets.
  file {
    '/opt/share/docker':
      ensure => directory,
      mode   => '0700';

    '/opt/share/docker/secrets':
      mode      => '0644',
      source    => 'puppet:///private-docker/',
      recurse   => true,
      purge     => true,
      force     => true,
      show_diff => false;

    # Create a couple scratch directories for sourcegraph to use for temporary
    # data storage
    #
    # This isn't great, but I think it's better than creating a whole new repo
    # for sourcegraph and this temporary directory only stores session
    # information and cloned repos anyway
    ['/opt/share/docker/sourcegraph', '/opt/share/docker/sourcegraph/redis']:
      ensure => directory,
      mode   => '0700';
  }
}
