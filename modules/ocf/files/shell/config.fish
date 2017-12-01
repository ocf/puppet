# Quit if not interactive
if not status --is-interactive
    exit
end

# OCF environment variables
set -x PATH /opt/share/utils/bin \
    /opt/share/utils/sbin \
    /usr/local/bin \
    /usr/local/sbin \
    /bin \
    /usr/bin \
    /usr/sbin \
    /usr/lib \
    /sbin \
    /usr/games

if test -e /opt/puppetlabs/bin
    set -x PATH $PATH /opt/puppetlabs/bin
end

set -x LANG en_US.UTF-8
set -x LC_ALL en_US.UTF-8

# Non-restrictive umask
umask 022

# Aliases
alias ls "ls -F"
alias quota "quota -Qs"
alias rm "rm -I"

# Logout
function on_exit --on-process %self
    if klist > /dev/null 2>&1
        kdestroy
    end
end
