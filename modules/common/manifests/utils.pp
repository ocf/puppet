class common::utils {
  vcsrepo { '/opt/share/utils':
    ensure   => latest,
    provider => git,
    revision => 'master',
    source   => 'https://github.com/ocf/utils.git';
  }
}
