Puppet::Functions.create_function(:'ldap_attr') do
  dispatch :up do
    param 'String', :host
    param 'String', :attr
  end

  def up(host, attr)
    # Shell out to ldapsearch, and use a regex to find the desired attribute
    #
    # Not the cleanest solution, but the ruby ldap library is a separate gem,
    # and it would be annoying to install it alongside puppet
    /^#{attr}: (.*)/.match(`/usr/bin/ldapsearch -LLL -x cn=#{host} #{attr}`)[1]
  end
end
