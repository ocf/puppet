Puppet::Functions.create_function(:'ldap_attr') do
  dispatch :up do
    param 'String',           :host
    param 'String',           :attr
    optional_param 'Boolean', :multi
  end

  def up(host, attr, multi = false)
    attrs = `/usr/bin/ldapsearch -LLL -x cn=#{host}`.
      scan(/#{attr}: (.*)/).
      flatten()
    return attrs.first if not multi
    attrs
  end
end
