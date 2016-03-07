class ocf_printhost::enforcer {
  # enforcer will probably depend on cups-tea4cups in the future
  package { ['cups-tea4cups', 'enforcer']: }
}
