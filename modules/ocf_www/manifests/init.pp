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
  include ocf::limits
  include ocf::packages::mysql
  include ocf::tmpfs
  include ocf_ssl

  class { 'ocf::nfs':
    pykota => false,
    cron   => false,
    web    => true,
  }

  class { '::apache':
    default_vhost => false,
    mpm_module    => 'worker',
  }

  # sites
  include ocf_www::site::shorturl
  include ocf_www::site::vhosts
  include ocf_www::site::ocfweb_redirects
  include ocf_www::site::www
}
