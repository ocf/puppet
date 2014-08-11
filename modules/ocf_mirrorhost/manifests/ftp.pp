class ocf_mirrorhost::ftp {
  package {
    ["vsftpd"]:;
  }

  service { "vsftpd":
    subscribe => File["/etc/vsftpd.conf"],
    require   => Package["vsftpd"];
  }

  file {
    "/etc/vsftpd.conf":
      source  => "puppet:///modules/ocf_mirrorhost/vsftpd.conf",
      require => Package["vsftpd"];
  }
}
