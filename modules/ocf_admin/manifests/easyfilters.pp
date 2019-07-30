class ocf_admin::easyfilters {
  user { 'ocfeasyfilters':
    comment => 'OCF user to use Gmail API to create inbox filters',
    shell   => '/bin/false',
  }

  # enable regular users to run easyfilters as ocfeasyfilters
  file { '/etc/sudoers.d/easyfilters':
    content => "ALL ALL=(ocfeasyfilters) NOPASSWD: /opt/share/utils/makeservices/easyfilters-real\n",
  }

  file {
    '/opt/share/easyfilters':
      ensure => directory,
      mode   => '0700',
      owner  => 'ocfeasyfilters';

    '/opt/share/easyfilters/easyfilters.yaml':
      source    => 'puppet:///private/easyfilters.yaml',
      show_diff => false;
  }
}
