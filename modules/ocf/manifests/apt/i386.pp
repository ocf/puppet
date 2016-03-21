# Add i386 multiarch support.
class ocf::apt::i386 {
  exec { 'add-i386':
    command => 'dpkg --add-architecture i386',
    unless  => 'dpkg --print-foreign-architectures | grep i386',
    notify => Exec['apt_update'];
  }
}
