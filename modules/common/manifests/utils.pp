class common::utils {
  vcsrepo { '/opt/share/utils':
    provider => git,
    ensure   => latest,
    revision => 'master',
    source   => 'git://github.com/ocf/utils.git';
  }
}
