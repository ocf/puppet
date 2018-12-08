Puppet::Functions.create_function(:'ldap_attr_multi') do
  dispatch :up do
    param 'String', :host
    param 'String', :attr
  end

  def up(host, attr)
    `/usr/bin/ldapsearch -LLL -x cn=#{host}`.
      scan(/#{attr}: (.*)/).
      flatten()
  end
end
