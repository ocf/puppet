class ocf_printhost::cups {
  package { ['cups', 'cups-bsd']: }

  service { 'cups':
    require   => Package['cups', 'cups-bsd'],
    subscribe => Class['ocf::ssl::default'],
  }

  file {
    default:
      require => Package['cups', 'cups-bsd'],
      notify  => Service['cups'];

    '/etc/cups/cupsd.conf':
      content => template('ocf_printhost/cups/cupsd.conf.erb');

    '/etc/apparmor.d/local/usr.sbin.cupsd':
      source => 'puppet:///modules/ocf_printhost/usr.sbin.cupsd';

    '/etc/cups/cups-files.conf':
      source => 'puppet:///modules/ocf_printhost/cups-files.conf';

    '/etc/cups/lpoptions':
      content => "Default double\n";

    ['/etc/cups/raw.convs', '/etc/cups/raw.types']:
      content => "# deny printing raw jobs\n";

    '/etc/cups/ppd':
      ensure => directory,
      group  => 'lp';

    '/etc/cups/printers.conf':
      replace => false,
      group   => 'lp',
      mode    => '0600',
      source  => 'puppet:///modules/ocf_printhost/cups/printers.conf';

    '/etc/cups/classes.conf':
      replace => false,
      group   => 'lp',
      mode    => '0600',
      source  => 'puppet:///modules/ocf_printhost/cups/classes.conf';

    '/usr/lib/cups/filter/ocfps/':
      source => 'puppet:///modules/ocf_printhost/ocfps',
      mode   => '0755';
  }

  ['logjam', 'papercut', 'pagefault'].each |String $printer| {
    file {
      default:
        group   => 'lp',
        require => Package['cups', 'cups-bsd'],
        notify  => Service['cups'];

      "/etc/cups/ppd/${printer}-single.ppd":
        content => epp('ocf_printhost/cups/ppd/m806.ppd.epp', { 'double' => false });

      "/etc/cups/ppd/${printer}-double.ppd":
        content => epp('ocf_printhost/cups/ppd/m806.ppd.epp', { 'double' => true });
    }
  }

  #Tea4cups saves files based on its owner
  file { '/usr/lib/cups/backend/tea4cups':
    ensure => 'file',
    owner  => 'ocfenforcer',
    mode   => '0700';
  }

  mount { '/var/spool/cups':
    device  => 'tmpfs',
    fstype  => 'tmpfs',
    options => 'uid=ocfenforcer,mode=0710,gid=lp,noatime,nodev,noexec,nosuid';
  }
}
