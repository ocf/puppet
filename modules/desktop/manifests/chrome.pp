class desktop::chrome {
  file {
    # policies
    ["/etc/opt", "/etc/opt/chrome", "/etc/opt/chrome/policies", "/etc/opt/chrome/policies/managed"]:
      ensure => directory;
    "/etc/opt/chrome/policies/managed/ocf_policy.json":
      source => "puppet:///modules/desktop/chrome/ocf_policy.json";
  }

  package {
    ["google-chrome-stable"]:;
  }
}
