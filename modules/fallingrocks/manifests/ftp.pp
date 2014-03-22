class fallingrocks::ftp {
  package {
    ["vsftpd"]:;
  }

  service { "vsftpd":
    subscribe => File["/etc/vsftpd.conf"],
    require   => Package["vsftpd"];
  }

  file {
    "/etc/vsftpd.conf":
      source  => "puppet:///modules/fallingrocks/vsftpd.conf",
      require => Package["vsftpd"];
  }
}
