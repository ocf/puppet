# ocf_www represents the main OCF webserver. It hosts:
#
#    * www.ocf.berkeley.edu (OCF's website and userdir websites)
#    * ocf.io (OCF's shorturl domain)
#    * virtual hosts
#
# In an effort to keep this configuration simple, we use our virtual hosting
# infrastructure as much as possible for internal websites. For example,
# phpMyAdmin is a normal vhost.
#
# The interesting config is in ocf_www::site::www, which sets up
# www.ocf.berkeley.edu, which is by far the most complicated domain.
class ocf_www {
  include ocf::acct
  include ocf::extrapackages
  include ocf::firewall::allow_web
  include ocf::limits
  include ocf::moinmoin
  include ocf::tmpfs
  include ocf::ssl::default

  class { 'ocf::nfs':
    cron => false,
    web  => false,
  }

  class {
    '::apache':
      log_formats => {
        # Log vhost name
        combined => '%v %h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"'
      },
      # "false" lets us define the class below with custom args
      mpm_module  => false;

    '::apache::mod::worker':
      startservers    => 8,
      # maxclients should be set to a max of serverlimit * threadsperchild
      maxclients      => 5000,
      threadsperchild => 50,
      serverlimit     => 100;
  }

  # Prometheus user needed for the prometheus-apache-exporter daemon,
  # which runs as user "prometheus"
  user {
    'prometheus':
      comment => 'prometheus user for running exporters',
      system  => true,
  }

  ocf::repackage {
    # prometheus-apache-exporter is only available in backports
    'prometheus-apache-exporter':
      backport_on => 'stretch';
  }

  # Restart apache if any cert changes occur
  Class['ocf::ssl::default'] ~> Class['Apache::Service']

  include ocf_www::lets_encrypt
  include ocf_www::logging
  include ocf_www::ssl

  # sites
  include ocf_www::site::ocfweb_redirects
  include ocf_www::site::shorturl
  include ocf_www::site::unavailable
  include ocf_www::site::vhosts
  include ocf_www::site::www
}
