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
#
# Nginx sits in front of Apache for slowloris protection.
# Nginx handles 80/443, Apache only listens on 127.0.0.1:$backend_port.
class ocf_www {
  # Port Apache listens on as nginx's backend (plain HTTP on localhost).
  # Must match BACKEND_PORT in build-vhosts.
  $backend_port = 16767

  # All Apache vhosts are backend-only (nginx handles 80/443).
  Apache::Vhost {
    ip   => '127.0.0.1',
    port => $backend_port,
  }

  include ocf::acct
  include ocf::extrapackages
  include ocf::firewall::allow_web
  include ocf::limits
  include ocf::tmpfs
  include ocf::ssl::default

  class { 'ocf::nfs':
    cron => false,
    web  => false,
  }

  # nginx reverse proxy
  include ocf_www::nginx

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
      maxrequestworkers => 5000,
      threadsperchild   => 50,
      serverlimit       => 100;
  }

  # Prometheus user needed for the prometheus-apache-exporter daemon,
  # which runs as user "prometheus"
  user {
    'prometheus':
      comment => 'prometheus user for running exporters',
  }

  ocf::repackage {
    # prometheus-apache-exporter is only available in backports
    'prometheus-apache-exporter':
      backport_on => 'stretch';
  }

  # Apache no longer serves SSL directly (nginx handles it), but mod_ssl is
  # still needed for SSLProxyEngine (outbound HTTPS to apphost).
  include apache::mod::ssl

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
