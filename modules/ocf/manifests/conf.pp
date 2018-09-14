define ocf::conf(
  $layout = {},
  $owner = 'root',
  $group = 'root',
  $mode = '0400',
  $show_diff = false,
  $force = true,
) {

  $builder = $layout.tree_each.map |$h| { [ $h[0], ocf::lookup_wrap($h[1]) ] }
  $config = Hash($builder, 'hash_tree')

  file { $title:
    ensure    => file,
    content   => template('ocf/conf.erb'),
    mode      => $mode,
    owner     => $owner,
    group     => $group,
    show_diff => $show_diff,
  }
}
