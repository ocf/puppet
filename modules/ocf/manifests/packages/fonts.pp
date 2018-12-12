# Install packages containing fonts.
#
# ocf_desktop and ocf_tv should both include this for consistency.
# For font rendering config, see ocf_desktop::xsession.
class ocf::packages::fonts {

  package {
    ['cm-super', 'fonts-croscore', 'fonts-crosextra-caladea',
      'fonts-crosextra-carlito', 'fonts-hack-otf', 'fonts-inconsolata',
      'fonts-linuxlibertine', 'fonts-noto-unhinted', 'fonts-symbola',
      'fonts-unfonts-core']:;
  }

  # contrib/non-free fonts - consider removing
  package { 'ttf-mscorefonts-installer': }

}
