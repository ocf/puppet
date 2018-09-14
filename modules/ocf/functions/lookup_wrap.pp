function ocf::lookup_wrap($item) {
  if $item =~ /^[a-zA-Z_:]*$/ {
    lookup($item)
  }
  else {
    $item
  }
}
