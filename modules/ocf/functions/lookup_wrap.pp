function ocf::lookup_wrap($item) {
  if String($item) =~ /^[a-zA-Z_:]*$/ {
    lookup(String($item))
  }
  else {
    $item
  }
}
