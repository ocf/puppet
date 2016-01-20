# mod_fastcgi configuration
#
# We use mod_fastcgi instead of the (otherwise superior and free-er) mod_fcgid
# because mod_fcgid doesn't support "-autoUpdate" (checking mtime of scripts
# and restarting the server process if it changes).
#
# Unfortunately this is an often-desired feature (lets you `touch` the script
# to start it again) which we need.
class ocf_www::mod::fastcgi {
  include apache::mod::fastcgi
  include apache::mod::suexec

  apache::custom_config { 'fastcgi_options':
    content => "
      FastCgiConfig -autoUpdate -killInterval 300 -maxProcesses 1000 -minProcesses 0
      FastCgiWrapper /usr/lib/apache2/suexec
    ",
  }
}
