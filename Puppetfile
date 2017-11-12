# Install all third-party modules into the vendor directory
moduledir 'vendor'


# Third-party modules, make sure to check their dependencies and add them here
# too, since r10k does not manage dependencies and you will be confused as to
# why they are not working properly.

# TODO: Upgrade puppet-nginx to 0.7.1
# (0.7.0 has a fair number of breaking changes)
mod 'puppet-nginx',                    '0.6.0'
mod 'puppetlabs-apache',               '2.2.0'
mod 'puppetlabs-apt',                  '4.2.0'
mod 'puppetlabs-concat',               '4.0.1'
#revert to puppetlabs-firewall when 1.9.1 released
mod 'kpengboy-firewall',               '1.9.0-79-gcb1bc3d-1'
mod 'puppetlabs-hocon',                '1.0.0'
mod 'puppetlabs-inifile',              '1.6.0' # Dependency of puppetlabs-puppetdb
mod 'puppetlabs-postgresql',           '5.0.0' # Dependency of puppetlabs-puppetdb
mod 'puppetlabs-puppet_authorization', '0.4.0'
mod 'puppetlabs-puppetdb',             '6.0.1'
mod 'puppetlabs-stdlib',               '4.20.0'
mod 'puppetlabs-tagmail',              '2.2.1'
mod 'puppetlabs-vcsrepo',              '2.0.0'
