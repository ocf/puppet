class ocf::packages::brave {
  class { 'ocf::packages::brave::apt':
    stage =>  first,
  }

  package { 'brave':; }

  # On Debian userns is compiled-in but disabled by deafult.
  # See more here: https://chromium.googlesource.com/chromium/src/+/lkcr/docs/linux_sandboxing.md#User-namespaces-sandbox
  sysctl { 'kernel.unprivileged_userns_clone': value =>  '1' }
}
