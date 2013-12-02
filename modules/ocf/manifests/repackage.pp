define ocf::repackage(
    $package    = $title,
    $recommends = undef,
    $backports  = undef,
    $dist       = $lsbdistcodename
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
}
