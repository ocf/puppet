# Include PowerShell apt repo
class ocf::packages::powershell::apt {
  apt::keyring { 'powershell.asc':
    source => 'https://packages.microsoft.com/keys/microsoft.asc';
  }
  if $facts['os']['distro']['codename'] == 'stretch' {
    apt::source { 'powershell':
        architecture => 'amd64',
        location     => 'https://packages.microsoft.com/repos/microsoft-debian-stretch-prod',
        release      => 'stretch',
        repos        => 'main',
        keyring      => '/etc/apt/keyrings/powershell.asc',
        require      => Apt::Keyring['powershell.asc'],
    }
  } else {
    apt::source { 'powershell':
      architecture => 'amd64',
      location     => "https://packages.microsoft.com/debian/${facts['os']['release']['major']}/prod",
      release      => $facts['os']['distro']['codename'],
      repos        => 'main',
      keyring      => '/etc/apt/keyrings/powershell.asc',
      require      => Apt::Keyring['powershell.asc'],
    }
  }
}
