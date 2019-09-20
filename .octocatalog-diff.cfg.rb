# This is a configuration file for octocatalog-diff (https://github.com/github/octocatalog-diff).
#
# To test this configuration file, run:
#   octocatalog-diff --config-test
#
# NOTE: This example file contains some of the more popular configuration options, but is
# not exhaustive of all possible configuration options. Any options that can be declared via the
# command line can also be set via this file. Please consult the options reference for more:
#   https://github.com/github/octocatalog-diff/blob/master/doc/optionsref.md
# And reference the source code to see how the underlying settings are constructed:
#   https://github.com/github/octocatalog-diff/tree/master/lib/octocatalog-diff/cli/options
# Also see the sample configuration file that includes more detailed comments about each option:
#   https://github.com/github/octocatalog-diff/blob/master/examples/octocatalog-diff.cfg.rb

module OctocatalogDiff
  class Config
    def self.config
      settings = {}

      settings[:hiera_config] = 'hiera.yaml'
      settings[:hiera_path] = 'hieradata'

      settings[:puppetdb_url] = 'https://puppetdb:8081'
      # TODO: Don't piggyback off the ocfweb puppet key/certs
      settings[:puppetdb_ssl_ca] = '/etc/ocfweb/puppet-certs/puppet-ca.pem'
      settings[:puppetdb_ssl_client_key] = File.read("/etc/ocfweb/puppet-certs/puppet-private.pem")
      settings[:puppetdb_ssl_client_cert] = File.read("/etc/ocfweb/puppet-certs/puppet-cert.pem")

      settings[:enc] = 'modules/ocf_puppet/files/ldap-enc'
      settings[:storeconfigs] = true
      settings[:bootstrap_script] = 'bin/bootstrap'
      settings[:puppet_binary] = '/opt/puppetlabs/bin/puppet'

      # TODO: Set this to origin/master once the octocatalog-diff changes are
      # merged to master
      settings[:from_env] = 'origin/octocatalog-diff-test'
      # This is used to cache third-party/vendored modules so that they don't
      # have to be installed each time (saves about 2 minutes per run, at least
      # on a host with relatively slow I/O like a staff VM, this is much faster
      # on reaper for instance)
      settings[:master_cache_branch] = settings[:from_env]

      settings[:validate_references] = %w(before notify require subscribe)
      settings[:header] = :default

      settings[:cached_master_dir] = File.join(
        (ENV['WORKSPACE'] || File.join(ENV['HOME'], '.cache')),
        '.octocatalog-diff-cache'
      )
      settings[:safe_to_delete_cached_master_dir] = settings[:cached_master_dir]

      # Use the workspace directory if it exists (on Jenkins), otherwise just
      # the current directory
      settings[:basedir] = (ENV['WORKSPACE'] || Dir.pwd)

      # This method must return the 'settings' hash.
      settings
    end
  end
end
