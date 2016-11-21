# create first stage to run before everything else
stage { 'first': before => Stage['main'] }

hiera_include(classes)
