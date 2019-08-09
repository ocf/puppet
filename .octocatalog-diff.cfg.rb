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
      settings[:puppetdb_ssl_ca] = 'keys/ca.pem'
      settings[:puppetdb_ssl_client_key] = File.read("keys/puppetboard.puppetdb.pem.private")
      settings[:puppetdb_ssl_client_cert] = File.read("keys/puppetboard.puppetdb.pem.cert")

      settings[:enc] = 'modules/ocf_puppet/files/ldap-enc'

      # TODO: Figure out why this has SSL errors when setting this to true
      # Have a look at https://github.com/github/octocatalog-diff/blob/master/doc/advanced-storeconfigs.md
      #settings[:storeconfigs] = true

      settings[:bootstrap_script] = 'bin/bootstrap'

      settings[:puppet_binary] = '/opt/puppetlabs/bin/puppet'

      # TODO: Set this back to origin/master once my changes are merged to master
      settings[:from_env] = 'origin/octocatalog-diff-test'

      settings[:validate_references] = %w(before notify require subscribe)
      settings[:header] = :default

      settings[:cached_master_dir] = File.join(ENV['HOME'], '.octocatalog-diff-cache')
      settings[:safe_to_delete_cached_master_dir] = settings[:cached_master_dir]

      settings[:basedir] = Dir.pwd
      # settings[:basedir] = ENV['WORKSPACE'] # May work with Jenkins

      # This method must return the 'settings' hash.
      settings
    end
  end
end
