class ocf::packages::emacs {
  ocf::repackage { 'emacs':
    backport_on => ['stretch'],
  }
}
