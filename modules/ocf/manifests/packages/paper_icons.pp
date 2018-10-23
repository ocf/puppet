class ocf::packages::paper_icons {

  class { 'ocf::packages::paper_icons::apt':
    stage =>  first,
  }

  package { 'paper-icon-theme':; }

}
