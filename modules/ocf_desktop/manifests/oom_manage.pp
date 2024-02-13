class ocf_desktop::oom_manage {
  sysctl {
    'vm.panic_on_oom': value => '1';
    'kernel.panic': value => '5';
  }
}
