define ocf::repackage(
    $package    = $title,
    $recommends = undef,
    $backports  = undef,
    $dist       = 'squeeze'
  ) {

  case $recommends {
    default,undef: { $r = '' }
    true:          { $r = '--with-recommends ' }
    false:         { $r = '--without-recommends ' }
    #true:  { $r = '--install-recommends ' }
    #false: { $r = '--no-install-recommends ' }
  }
  case $backports {
    default,undef: { $b = '' }
    true:          { $b = "-t ${dist}-backports " }
    false:         { $b = '' }
  }

  exec { "aptitude install $package":
    command => "aptitude -y ${r}${b}install $package",
    unless  => "dpkg -l $package | grep ^ii"
  }
  #exec { "apt-get install $package":
    #command => "apt-get -y --force-yes ${r}${b}install $package",
    #unless  => "dpkg -l $package | grep ^ii"
  #}

}
