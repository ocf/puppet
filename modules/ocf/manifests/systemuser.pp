define ocf::systemuser(
  $ensure = present,
  $opts = {},
  $groups = [],
){

  $groups_real = $groups ? {
    Array   => $groups + ['sys'],
    String  => [$groups, 'sys'],
    default => ['sys'],
  }

  user { $title:
    ensure => $ensure,
    system => true,
    groups => $groups_real,
    *      => $opts,
  }
}
