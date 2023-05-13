# Include PowerShell apt repo
class ocf::packages::powershell::apt {
  apt::key { 'powershell repo key':
    id     => 'BC528686B50D79E339D3721CEB3E94ADBE1229CF',
    source => 'https://packages.microsoft.com/keys/microsoft.asc';
  }
  if $::lsbdistcodename == 'stretch' {
    apt::source { 'powershell':
        architecture => 'amd64',
        location     => 'https://packages.microsoft.com/repos/microsoft-debian-stretch-prod',
        release      => 'stretch',
        repos        => 'main',
        require      => Apt::Key['powershell repo key'],
    }
  } elsif $::lsbdistcodename == 'bookworm' {
    apt::source { 'powershell':
      architecture => 'amd64',
      location     => "https://packages.microsoft.com/debian/11/prod",
      release      => 'bullseye',
      repos        => 'main',
      require      => Apt::Key['powershell repo key'],
    }
  } else {
    apt::source { 'powershell':
      architecture => 'amd64',
      location     => "https://packages.microsoft.com/debian/${::operatingsystemmajrelease}/prod",
      release      => $::lsbdistcodename,
      repos        => 'main',
      require      => Apt::Key['powershell repo key'],
    }
  }
}
