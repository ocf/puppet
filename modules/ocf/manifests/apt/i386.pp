# Add i386 multiarch support.
#
# This is a wrapper class to allow multiple manifests to include i386 support
# without declaring the first stage class multiple times.

class ocf::apt::i386 {
  class { 'ocf::apt::i386::first_stage':
    stage => first,
  }
}
