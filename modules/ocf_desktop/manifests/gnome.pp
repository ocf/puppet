class ocf_desktop::gnome {
  package { ['gnome-core']:; }

  ocf_desktop::dconf::profile { 'Defaults':
    target  => 'user',
    entries => {
      'user' => {
        'type'  => 'user',
        'order' => 1,
      },
      'local' => {
        'type'  => 'system',
        'order' => 20,
      },
      'site' => {
        'type'  => 'system',
        'order' => 30,
      },
    },
  }

  ocf_desktop::dconf::settings { 'OCF user defaults':
    profile       => 'site',
    settings_hash => {
      'org/gnome/desktop/lockdown' => {
        'disable-user-switching' => {
          'value' => true,
          'lock'  => true,
        },
        'disable-lock-screen' => {
          'value' => true,
          'lock'  => true,
        },
      },
      'org/gnome/desktop/background' => {
        'picture-uri' => {
          'value' => "'file:///opt/share/xsession/images/background.png'",
          'lock'  => false,
        },
      },
      'org/gnome/settings-daemon/plugins/power' => {
        'sleep-inactive-ac-timeout' => {
          'value' => 0,
          'lock'  => true,
        },
        'idle-dim' => {
          'value' => false,
          'lock'  => true,
        },
      },
    },
  }
}
