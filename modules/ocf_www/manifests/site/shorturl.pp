class ocf_www::site::shorturl {
  # TODO: Remove this cert and replace with Let's Encrypt
  # Make sure this gets renewed before Jan 21 2018
  file {
    '/etc/ssl/private/ocf.io.crt':
      source => 'puppet:///private/ssl/ocf.io.crt',
      mode   => '0644',
      notify => Service['httpd'];
  }

  $canonical_url = $::hostname ? {
    /^dev-/ => 'https://dev-ocf-io.ocf.berkeley.edu/',
    default => 'https://ocf.io/',
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
      {rewrite_rule => '^/absa$ https://drive.google.com/drive/folders/0B7n5VUVfGPUoV0xPREIwY0hzc0E?usp=sharing [R]'},
      {rewrite_rule => '^/account$ https://www.ocf.berkeley.edu/docs/services/account/ [R]'},
      {rewrite_rule => '^/apphost$ https://www.ocf.berkeley.edu/docs/services/webapps/ [R]'},
      {rewrite_rule => '^/bod(/.*)?$ https://www.ocf.berkeley.edu/~staff/bod$1 [R]'},
      {rewrite_rule => '^/buy$ https://goo.gl/forms/S4DbENwDV2utnYPG3 [R]'},
      {rewrite_rule => '^/buysheet$ https://docs.google.com/a/ocf.berkeley.edu/spreadsheets/d/1ylEgN2RP0CifGBMNnG3I0P1F5H9GbHetBMb4I2Osa6k/edit?usp=sharing [R]'},
      {rewrite_rule => '^/callinkapi$ https://studentservices.berkeley.edu/WebServices/StudentGroupServiceV2/Service.asmx/CalLinkOrganizations [R]'},
      {rewrite_rule => '^/contact$ https://www.ocf.berkeley.edu/docs/contact/ [R]'},
      {rewrite_rule => '^/decal(/.*)?$ https://decal.ocf.berkeley.edu$1 [R]'},
      {rewrite_rule => '^/docs(/.*)?$ https://www.ocf.berkeley.edu/docs$1 [R]'},
      {rewrite_rule => '^/email-update$ http://status.ocf.berkeley.edu/2014/06/email-discontinuation-update-forward.html [R]'},
      {rewrite_rule => '^/faq$ https://www.ocf.berkeley.edu/docs/faq/ [R]'},
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
      {rewrite_rule => '^/joinfamily$ https://goo.gl/forms/POOjVhW7pUw21myP2 [R]'},
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
      {rewrite_rule => '^/senate-resolution$ https://docs.google.com/document/d/1UwjX4BJIzeQ6XjGBHu2rA51XUjywTBtPTzJN2CMGU4o/edit [R]'},
      {rewrite_rule => '^/servers$ https://www.ocf.berkeley.edu/docs/staff/backend/servers/ [R]'},
      {rewrite_rule => '^/shorturl$ https://github.com/ocf/puppet/blob/master/modules/ocf_www/manifests/site/shorturl.pp [R]'},
      {rewrite_rule => '^/ssh$ https://www.ocf.berkeley.edu/docs/services/shell/ [R]'},
      {rewrite_rule => '^/staff$ https://www.ocf.berkeley.edu/about/staff [R]'},
      {rewrite_rule => '^/staffhours$ https://ocf.io/staff-hours [R]'},
      {rewrite_rule => '^/staff-hours$ https://www.ocf.berkeley.edu/staff-hours [R]'},
      {rewrite_rule => '^/staff_hours$ https://ocf.io/staff-hours [R]'},
      {rewrite_rule => '^/stats$ https://www.ocf.berkeley.edu/stats/ [R]'},
      {rewrite_rule => '^/status$ http://status.ocf.berkeley.edu/ [R]'},
      {rewrite_rule => '^/stretch$ https://www.ocf.berkeley.edu/docs/staff/backend/stretch/ [R]'},
      {rewrite_rule => '^/stf-cost-breakdown$ https://docs.google.com/spreadsheets/d/1U3YfU5S1hyi4c9u1vME84lz5hQPz23LKWCaD8mq4JHI/edit [R]'},
      {rewrite_rule => '^/tw(/.*)?$ https://ocf.io/twitter$1 [R]'},
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
