# Add i386 multiarch support.
#
# This is the inner first-stage class which should never be used directly.
# Instead, you should include `ocf::apt::i386` in order to allow multiple
# manifests to require i386 support without redeclaring a class with
# parameters.

class ocf::apt::i386::first_stage {
  exec { 'add-i386':
    command => 'dpkg --add-architecture i386',
    unless  => 'dpkg --print-foreign-architectures | grep i386',
    notify => Exec['apt_update'];
  }
}
