# Quit if no prompt
if(! $?prompt) exit

setenv PATH /opt/share/utils/bin:/opt/share/utils/sbin:/usr/local/bin:/usr/local/sbin:/opt/puppetlabs/bin:/bin:/usr/bin:/usr/sbin:/usr/lib:/sbin:/usr/games
setenv LANG en_US.UTF-8
setenv LC_ALL en_US.UTF-8
setenv MAIL /var/mail/$USER

# Non-restrictive umask
umask 022

alias ls ls -F
alias quota quota -Qs
alias rm rm -I

set prompt = "%m[%c]"

# Allow user customizations to take precedence
if (-r ~/.cshrc.local) source ~/.cshrc.local
