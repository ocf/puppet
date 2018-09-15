function ocf::lookup_wrap($item) {
  $item ? {
    String  => lookup($item),
    default => $item,
  }
}
