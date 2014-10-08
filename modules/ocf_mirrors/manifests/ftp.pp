class ocf_mirrors::ftp {
  package {
    ['vsftpd']:;
  }

  service { 'vsftpd':
    subscribe => File['/etc/vsftpd.conf'],
    require   => Package['vsftpd'];
  }

  file {
    '/etc/vsftpd.conf':
      source  => 'puppet:///modules/ocf_mirrors/vsftpd.conf',
      require => Package['vsftpd'];
  }
}
