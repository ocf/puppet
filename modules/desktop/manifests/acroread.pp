class desktop::acroread {

  package { 'acroread': }

  # required dependency on debian squeeze
  if $::lsbdistcodename == 'squeeze' {
    package { 'ia32-libs-gtk': }
  }

  # hide EULA
  file { '/usr/lib/Adobe/Reader9/Reader/GlobalPrefs/reader_prefs':
    source => 'puppet:///modules/desktop/acroread_prefs',
  }

}
