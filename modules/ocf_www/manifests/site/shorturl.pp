class ocf_www::site::shorturl {
  # TODO: Remove this cert and replace with Let's Encrypt
  # Make sure this gets renewed before Jan 21 2018
  file {
    '/etc/ssl/private/ocf.io.crt':
      source => 'puppet:///private/ssl/ocf.io.crt',
      mode   => '0644',
      notify => Service['httpd'];
  }

  $canonical_url = $::host_env ? {
    'dev'  => 'https://dev-ocf-io.ocf.berkeley.edu/',
    'prod' => 'https://ocf.io/',
  }

  apache::vhost { 'shorturl':
    servername    => 'ocf.io',
    serveraliases => ['dev-ocf-io.ocf.berkeley.edu', 'www.ocf.io'],
    port          => 443,
    docroot       => '/var/www/html',

    ssl           => true,
    ssl_key       => '/etc/ssl/lets-encrypt/le-vhost.key',
    ssl_cert      => '/etc/ssl/private/ocf.io.crt',
    ssl_chain     => '/etc/ssl/certs/lets-encrypt.crt',

    rewrites      => [
      # Short URLs
      # Remember to add these to the list of RESERVED_USERNAMES in ocflib/account/validators.py
      {rewrite_rule => '^/?$ https://www.ocf.berkeley.edu/ [R=301]'},
      {rewrite_rule => '^/about$ https://www.ocf.berkeley.edu/docs/about/ [R]'},
      {rewrite_rule => '^/account$ https://www.ocf.berkeley.edu/docs/services/account/ [R]'},
      {rewrite_rule => '^/apphost(ing)?$ https://www.ocf.berkeley.edu/docs/services/webapps/ [R]'},
      {rewrite_rule => '^/bod(/.*)?$ https://www.ocf.berkeley.edu/~staff/bod$1 [R]'},
      {rewrite_rule => '^/callinkapi$ https://studentservices.berkeley.edu/WebServices/StudentGroupServiceV2/Service.asmx/CalLinkOrganizations [R]'},
      {rewrite_rule => '^/contact$ https://www.ocf.berkeley.edu/docs/contact/ [R]'},
      {rewrite_rule => '^/decal(/.*)?$ https://decal.ocf.berkeley.edu$1 [R]'},
      {rewrite_rule => '^/docs(/.*)?$ https://www.ocf.berkeley.edu/docs$1 [R]'},
      {rewrite_rule => '^/eligibility$ https://www.ocf.berkeley.edu/docs/membership/eligibility/ [R]'},
      {rewrite_rule => '^/email-update$ http://status.ocf.berkeley.edu/2014/06/email-discontinuation-update-forward.html [R]'},
      {rewrite_rule => '^/facebook$ https://goo.gl/forms/dEzJmyRMwAPWCDAY2 [R]'},
      {rewrite_rule => '^/faq$ https://www.ocf.berkeley.edu/docs/faq/ [R]'},
      {rewrite_rule => '^/gh/([^/]*)(/(?!blob/)(?!tree/)(?!info/)(?!issue)(?!pull).+)$ https://ocf.io/gh/$1/blob/master$2 [R]'},
      {rewrite_rule => '^/gh/l(/.*)?$ https://github.com/ocf/ocflib$1 [R]'},
      {rewrite_rule => '^/gh/p(/.*)?$ https://github.com/ocf/puppet$1 [R]'},
      {rewrite_rule => '^/gh/u(/.*)?$ https://github.com/ocf/utils$1 [R]'},
      {rewrite_rule => '^/gh/w(/.*)?$ https://github.com/ocf/ocfweb$1 [R]'},
      {rewrite_rule => '^/gh(/.*)?$ https://ocf.io/github$1 [R]'},
      {rewrite_rule => '^/github(/.*)?$ https://github.com/ocf$1 [R]'},
      {rewrite_rule => '^/gadmin$ https://admin.google.com/a/ocf.berkeley.edu [R]'},
      {rewrite_rule => '^/gcal$ https://calendar.google.com/a/ocf.berkeley.edu [R]'},
      {rewrite_rule => '^/gmail$ https://mail.google.com/a/ocf.berkeley.edu [R]'},
      {rewrite_rule => '^/gdrive$ https://drive.google.com/a/ocf.berkeley.edu [R]'},
      {rewrite_rule => '^/guest$ https://goo.gl/forms/ImNfnZkrRrakZcIr1 [R]'},
      {rewrite_rule => '^/help(/.*)?$ https://www.ocf.berkeley.edu/docs$1 [R]'},
      {rewrite_rule => '^/hiring$ https://www.ocf.berkeley.edu/announcements/2017-03-20/hiring [R]'},
      {rewrite_rule => '^/hosting$ https://www.ocf.berkeley.edu/docs/services/web/ [R]'},
      {rewrite_rule => '^/hours$ https://ocf.io/lab#hours [R,NE]'},
      {rewrite_rule => '^/https$ http://status.ocf.berkeley.edu/2014/10/moving-wwwocfberkeleyedu-to-https-only.html [R]'},
      {rewrite_rule => '^/job$ https://docs.google.com/document/d/1oS3ma415LbtuyeEuuoucWKYLcWOJaWmzhv2nIs5f718/edit [R]'},
      {rewrite_rule => '^/join$ https://www.ocf.berkeley.edu/account/register/ [R]'},
      {rewrite_rule => '^/register$ https://www.ocf.berkeley.edu/account/register/ [R]'},
      {rewrite_rule => '^/lab$ https://www.ocf.berkeley.edu/docs/services/lab/ [R]'},
      {rewrite_rule => '^/mail$ https://www.ocf.berkeley.edu/docs/services/vhost/mail/ [R]'},
      {rewrite_rule => '^/mailrequest$ https://www.ocf.berkeley.edu/account/vhost/mail/ [R]'},
      {rewrite_rule => '^/minutes(/.*)?$ https://www.ocf.berkeley.edu/~staff/bod$1 [R]'},
      {rewrite_rule => '^/mlk$ https://www.ocf.berkeley.edu/mlk [R]'},
      {rewrite_rule => '^/mon$ https://munin.ocf.berkeley.edu/ [R]'},
      {rewrite_rule => '^/mysql$ https://www.ocf.berkeley.edu/docs/services/mysql/ [R]'},
      {rewrite_rule => '^/password$ https://www.ocf.berkeley.edu/account/password [R]'},
      {rewrite_rule => '^/printing$ https://www.ocf.berkeley.edu/announcements/2016-02-09/printing [R]'},
      {rewrite_rule => '^/rt$ https://rt.ocf.berkeley.edu/ [R]'},
      {rewrite_rule => '^/rt/([0-9]+)$ https://rt.ocf.berkeley.edu/Ticket/Display.html?id=$1 [R]'},
      {rewrite_rule => '^/s(/[^/]*)$ https://www.ocf.berkeley.edu/~staff/short_urls$1 [R]'},
      {rewrite_rule => '^/senate-resolution$ https://docs.google.com/document/d/1UwjX4BJIzeQ6XjGBHu2rA51XUjywTBtPTzJN2CMGU4o/edit [R]'},
      {rewrite_rule => '^/servers$ https://www.ocf.berkeley.edu/docs/staff/backend/servers/ [R]'},
      {rewrite_rule => '^/shorturl$ https://github.com/ocf/puppet/blob/master/modules/ocf_www/manifests/site/shorturl.pp [R]'},
      {rewrite_rule => '^/ssh$ https://www.ocf.berkeley.edu/docs/services/shell/ [R]'},
      {rewrite_rule => '^/staff$ https://www.ocf.berkeley.edu/about/staff [R]'},
      {rewrite_rule => '^/staff[-_]?hours$ https://www.ocf.berkeley.edu/staff-hours [R]'},
      {rewrite_rule => '^/stats$ https://www.ocf.berkeley.edu/stats/ [R]'},
      {rewrite_rule => '^/status$ http://status.ocf.berkeley.edu/ [R]'},
      {rewrite_rule => '^/stretch$ https://www.ocf.berkeley.edu/docs/staff/backend/stretch/ [R]'},
      {rewrite_rule => '^/survey$ https://goo.gl/forms/nP3ijHvqn5SE4bGh1 [R]'},
      {rewrite_rule => '^/twitter(/.*)?$ https://twitter.com/ucbocf$1 [R]'},
      {rewrite_rule => '^/tv(/.*)?$ https://www.ocf.berkeley.edu/tv$1 [R]'},
      {rewrite_rule => '^/vhost$ https://www.ocf.berkeley.edu/docs/services/vhost/ [R]'},
      {rewrite_rule => '^/vhost-mail$ https://www.ocf.berkeley.edu/docs/services/vhost/mail/ [R]'},
      {rewrite_rule => '^/wiki$ https://www.ocf.berkeley.edu/docs/ [R]'},
      {rewrite_rule => '^/wordpress$ https://www.ocf.berkeley.edu/docs/services/web/wordpress/ [R]'},
      {rewrite_rule => '^/web$ https://www.ocf.berkeley.edu/docs/services/web/ [R]'},
      {rewrite_rule => '^/xkcd$ https://xkcd.ocf.berkeley.edu/ [R]'},
      {rewrite_rule => '^/youtube$ https://www.youtube.com/channel/UCx6SI8vROy9UGje0IiLkk8w [R]'},

      # Otherwise, send a temporary redirect to the appropriate userdir
      {rewrite_rule => '^/~?([a-z]{3,16}(?:/.*)?)$ https://www.ocf.berkeley.edu/~$1 [R]'},
    ],

    headers       => ['always set Strict-Transport-Security "max-age=31536000; includeSubDomains; preload"'],
  }

  # canonical redirects
  apache::vhost { 'shorturl-http-redirect':
    servername      => 'ocf.io',
    serveraliases   => ['dev-ocf-io.ocf.berkeley.edu', 'www.ocf.io'],
    port            => 80,
    docroot         => '/var/www/html',

    redirect_status => 301,
    redirect_dest   => $canonical_url;
  }
}
