# Unfortunately it's not possible to write external facts (i.e. facts written
# in languages other than Ruby) that output structured data (non-strings).
#
# So, we dump JSON from our Python script and parse it in the Ruby fact. Yuck.

require 'json'

PYTHON_SCRIPT = '/usr/local/bin/parse-vhosts'

Facter.add(:ocf_vhosts) do
  setcode do
    # During the first Puppet run, the script won't exist yet. Not much we can
    # do about that since Facter is always run before Puppet is.
    if File.exist?(PYTHON_SCRIPT)
      ocf_vhosts = JSON.parse(Facter::Core::Execution.exec(PYTHON_SCRIPT))
    else
      ocf_vhosts = []
    end

    ocf_vhosts
  end
end
