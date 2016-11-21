# TODO: this feels pretty hacky, but we need to load this last or the variables
# in site.pp and site_ssl.pp don't get loaded?
hiera_include(classes)
