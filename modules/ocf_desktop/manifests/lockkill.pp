# Kill sessions that stay in the locked state for too long
class ocf_desktop::lockkill {
  user { 'ocflockkill':
    ensure => present,
    shell  => '/bin/false',
  }

  file {
    '/opt/share/puppet/lockkill':
      source  => 'puppet:///modules/ocf_desktop/lockkill/lockkill',
      mode    => '0755',
      require =>  File['/opt/share/puppet'];
    '/etc/polkit-1/localauthority/90-mandatory.d/99-lockkill.pkla':
      # Workaround for bug causing polkit rules to be ignored - the
      # contents of this file have been merged into 99-ocf.pkla
      ensure => absent;
  }

  ocf::systemd::service { 'lockkill':
    source    => 'puppet:///modules/ocf_desktop/lockkill/lockkill.service',
    require   => [
      User['ocflockkill'],
      File['/etc/polkit-1/localauthority/90-mandatory.d/99-lockkill.pkla'],
    ],
    subscribe => File['/opt/share/puppet/lockkill'],
  }
}
