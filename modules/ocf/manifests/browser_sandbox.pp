class ocf::browser_sandbox {
  # Change kernel settings for the sandbox used by Brave, Chrome, and Firefox.
  # Verify sandbox status at brave://sandbox, chrome://sandbox, about:support,
  # respectively.
  sysctl {
    # Distributions like Debian currently disable unprivileged user namespaces
    # by default to decrease the kernel attack surface for local privilege
    # escalation. See Debian bug #898446. If kept disabled, Brave 1.2+ and
    # Chrome will still enforce namespace sandboxing via their setuid-root
    # helper executable. See brave/brave-browser#3420 and
    # brave/brave-browser#6247. Firefox does not include a setuid-root binary,
    # however, so unprivileged user namespaces are useful to have for
    # defense in depth, but not critical. See
    # <https://www.morbo.org/2018/05/linux-sandboxing-improvements-in_10.html>.
    'kernel.unprivileged_userns_clone':
      ensure => absent;
    # Enable ptrace protection. Only allow ptrace from a parent process to its
    # children or via CAP_SYS_PTRACE. This is also set by hardening-runtime.
    'kernel.yama.ptrace_scope':
      value => '1';
  }
}
