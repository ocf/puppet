class ocf_desktop::gdm {

  ocf_desktop::dconf::profile { 'gdm':
    entries => {
      'user' => {
        'type'  => 'user',
        'order' => 1,
      },
      'gdm'  => {
        'type' => 'system',
        'order' => 15,
      },
      '/var/lib/gdm3/greeter-dconf-defaults' => {
        'type'  => 'file',
        'order' => 99,
      },
    }
  }

  ocf_desktop::dconf::settings { 'GDM Dconf Settings':
    profile       => 'gdm',
    settings_hash => {
      'org/gnome/login-screen' => {
        'disable-restart-buttons' => {
          'value' => true,
        },
        'disable-user-list' => {
          'value' => true,
        },
        'banner-message-enable' => {
          'value' => true,
        },
        'banner-message-text' => {
          'value' => "'Welcome to the OCF!'",
        },
      },
      'org/gnome/settings-daemon/plugins/power' => {
        'sleep-inactive-ac-timeout' => {
          'value' => 0,
        },
        'idle-dim' => {
          'value' => false,
        },
      },
      'org/gnome/desktop/session' => {
        'idle-delay' => {
          'value' => 0,
        },
      },
    },
  }
}
