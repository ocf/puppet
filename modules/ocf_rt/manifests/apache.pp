class ocf_rt::apache {
  class { '::apache':
    mpm_module    => 'prefork',
    default_vhost => false;
  }

  include apache::mod::alias
  include apache::mod::auth_kerb
  include apache::mod::perl
  include apache::mod::rewrite


  # redirect to SSL
  apache::vhost { 'rt.ocf.berkeley.edu-redirect':
    servername      => 'rt.ocf.berkeley.edu',
    serveraliases   => ['rt'],
    port            => 80,
    docroot         => '/var/www',
    redirect_status => 301,
    redirect_dest   => 'https://rt.ocf.berkeley.edu';
  }

  apache::vhost { 'rt.ocf.berkeley.edu':
    servername => 'rt.ocf.berkeley.edu',
    port       => 443,
    docroot    => '/usr/share/request-tracker4/html',

    ssl        => true,
    ssl_key    => "/etc/ssl/private/${::fqdn}.key",
    ssl_cert   => "/etc/ssl/private/${::fqdn}.crt",
    ssl_chain  => '/etc/ssl/certs/incommon-intermediate.crt',

    headers    => 'set Strict-Transport-Security "max-age=31536000"',

    rewrites => [{
      rewrite_rule => '^/t/(\d+) /Ticket/Display.html?id=$1 [R,L]'
    }],

    directories => [
      {
        path            => '/',
        provider        => 'location',
        sethandler      => 'modperl',
        auth_type       => 'Kerberos',
        auth_require    => 'valid-user',

        custom_fragment => "
          PerlResponseHandler Plack::Handler::Apache2
          PerlSetVar psgi_app /usr/share/request-tracker4/libexec/rt-server

          KrbMethodNegotiate On
          KrbMethodK5Passwd On
          KrbLocalUserMapping On
          KrbServiceName HTTP/${::fqdn}
          Krb5KeyTab /etc/rt.keytab"
      },

      # allow access to REST API to mail server (anthrax) and IRC bots (locusts) without Kerberos
      {
        path         => '/REST/1.0',
        provider     => 'location',
        auth_require => 'ip 127.0.0.1 169.229.10.35 169.229.10.201'
      },
    ],

    custom_fragment => '
      <Perl>
      use Plack::Handler::Apache2;
      Plack::Handler::Apache2->preload("/usr/share/request-tracker4/libexec/rt-server");
      </Perl>
      ',

    require => [Package['request-tracker4'], Exec['install-commandbymail', 'install-mergeusers']];
  }
}
