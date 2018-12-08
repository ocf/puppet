define ocf::systemuser(
  $ensure = present,
  $opts = {},
){

  $groups_real = $opts['groups'] ? {
    Array   => $opts['groups'] + ['sys'],
    String  => [$opts['groups'], 'sys'],
    default => ['sys'],
  }
  $updated = { 'groups' =>  $groups_real }
  # Rightmost hash takes precedence on merge
  $updated_opts = $opts + $updated

  user { $title:
    ensure => $ensure,
    system => true,
    *      => $opts,
  }
}
