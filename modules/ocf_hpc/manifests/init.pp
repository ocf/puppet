class ocf_hpc {
  # install proprietary nvidia drivers
  package { ['nvidia-driver', 'nvidia-settings', 'nvidia-cuda-toolkit']:; }
}
