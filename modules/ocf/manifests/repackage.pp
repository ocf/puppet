define ocf::repackage(
    $package    = $title,
    $recommends = undef,
    $backports  = undef,
    $dist       = $::lsbdistcodename,
  ) {

  case $recommends {
    default, undef: { $r = '' }
    true:           { $r = '--with-recommends ' }
    false:          { $r = '--without-recommends ' }
  }

  if ($dist == 'wheezy') and ($architecture != 'armv6l') and
     ($backports == true) {
    $b = "-t ${dist}-backports "
    $g = '| grep ~bpo'
  }
  else {
    $b = ''
    $g = ''
  }

  exec { "aptitude install $package":
    command => "aptitude -y ${r}${b}install $package",
    unless  => "dpkg -l $package | grep ^ii $g"
  }

}
