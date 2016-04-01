# Declares that the following user is to have a persistent per-user systemd
define ocf_apphost::systemd_linger($user = $title) {
  file { "/var/lib/systemd/linger/${user}":
    ensure => file;
  }
}
