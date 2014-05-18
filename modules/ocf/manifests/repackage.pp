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
  }
  case $backports {
    default,undef: { $b = '' $g = '' }
    true:          { $b = "-t ${dist}-backports " $g = '| grep ~bpo' }
    false:         { $b = '' $g = '' }
  }

  exec { "aptitude install $package":
    command => "aptitude -y ${r}${b}install $package",
    unless  => "dpkg -l $package | grep ^ii $g"
  }
}
