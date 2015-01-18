# OCF port of the puppet `pip` package provider for pip3.
#
# Source is almost identical to the pip provider source:
# https://github.com/puppetlabs/puppet/blob/master/lib/puppet/provider/package/pip.rb
#
# The only changes are for the binary name, plus a check to handle Debian
# jessie/wheezy inconsistent naming of pip3
#
# There is a relevant issue tracking the inclusion of a pip3 provider:
# https://tickets.puppetlabs.com/browse/PUP-3480

require 'puppet/provider/package'
require 'xmlrpc/client'

Puppet::Type.type(:package).provide :pip3,
  :parent => ::Puppet::Provider::Package do

  desc "Python packages via `pip3`."

  has_feature :installable, :uninstallable, :upgradeable, :versionable

  # Parse lines of output from `pip freeze`, which are structured as
  # _package_==_version_.
  def self.parse(line)
    if line.chomp =~ /^([^=]+)==([^=]+)$/
      {:ensure => $2, :name => $1, :provider => name}
    else
      nil
    end
  end

  # Return an array of structured information about every installed package
  # that's managed by `pip` or an empty array if `pip` is not available.
  def self.instances
    packages = []
    pip_cmd = which(cmd) or return []
    execpipe "#{pip_cmd} freeze" do |process|
      process.collect do |line|
        next unless options = parse(line)
        packages << new(options)
      end
    end
    packages
  end

  def self.cmd
    # On Debian < 8, the pip3 binary doesn't exist; instead it's named "pip-3.2".
    if Facter.value(:osfamily) == "Debian" and Facter.value(:operatingsystemmajrelease).to_i < 8
      "pip-3.2"
    else
      "pip3"
    end
  end

  # Return structured information about a particular package or `nil` if
  # it is not installed or `pip` itself is not available.
  def query
    self.class.instances.each do |provider_pip|
      return provider_pip.properties if @resource[:name].downcase == provider_pip.name.downcase
    end
    return nil
  end

  # Ask the PyPI API for the latest version number.  There is no local
  # cache of PyPI's package list so this operation will always have to
  # ask the web service.
  def latest
    client = XMLRPC::Client.new2("http://pypi.python.org/pypi")
    client.http_header_extra = {"Content-Type" => "text/xml"}
    client.timeout = 10
    result = client.call("package_releases", @resource[:name])
    result.first
  rescue Timeout::Error => detail
    raise Puppet::Error, "Timeout while contacting pypi.python.org: #{detail}", detail.backtrace
  end

  # Install a package.  The ensure parameter may specify installed,
  # latest, a version number, or, in conjunction with the source
  # parameter, an SCM revision.  In that case, the source parameter
  # gives the fully-qualified URL to the repository.
  def install
    args = %w{install -q}
    if @resource[:source]
      if String === @resource[:ensure]
        args << "#{@resource[:source]}@#{@resource[:ensure]}#egg=#{
          @resource[:name]}"
      else
        args << "#{@resource[:source]}#egg=#{@resource[:name]}"
      end
    else
      case @resource[:ensure]
      when String
        args << "#{@resource[:name]}==#{@resource[:ensure]}"
      when :latest
        args << "--upgrade" << @resource[:name]
      else
        args << @resource[:name]
      end
    end
    lazy_pip *args
  end

  # Uninstall a package.  Uninstall won't work reliably on Debian/Ubuntu
  # unless this issue gets fixed.
  # <http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=562544>
  def uninstall
    lazy_pip "uninstall", "-y", "-q", @resource[:name]
  end

  def update
    install
  end

  # Execute a `pip` command.  If Puppet doesn't yet know how to do so,
  # try to teach it and if even that fails, raise the error.
  private
  def lazy_pip(*args)
    pip *args
  rescue NoMethodError => e
    if pathname = which(self.class.cmd)
      self.class.commands :pip => pathname
      pip *args
    else
      raise e, 'Could not locate the pip command.', e.backtrace
    end
  end
end
