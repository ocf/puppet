# We use a single root password across all OCF machines. We use a stupid number
# of iterations of SHA-512 so that the hash itself is not valuable.
#
# The root password is a last resort that is only used in rare cases where
# there is no other option.
#
# To regenerate the root password, see /opt/share/utils/staff/puppet/gen-rootpw
class ocf::rootpw($stage = 'first') {
  user { 'root':
    groups   => ['root'],
    password => Sensitive(file('/opt/puppet/shares/private/rootpw')),
  }
}
