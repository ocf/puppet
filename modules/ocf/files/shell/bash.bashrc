# Quit if no prompt
[ -z "$PS1" ] && return

# Standard environment variables
export PATH=/opt/share/utils/bin:/opt/share/utils/sbin:/usr/local/bin:\
/usr/local/sbin:/bin:/usr/bin:/usr/sbin:/usr/lib:/sbin:/usr/games
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export MAIL=/var/mail/$USER

# Non-restrictive umask
umask 022

# Set up bash-completion
[ -r /etc/bash_completion ] && source /etc/bash_completion

# No duplicate lines in shell history
HISTCONTROL=ignoreboth

# Aliases
alias ls='ls -Fh'
alias quota='/usr/bin/quota -Qs'
alias rm='rm -I'

# Color terminal
if [ "$TERM" != dumb ]; then
  PS1='\[\e[0;31m\]\u\[\e[m\]@\[\e[m\]\[\e[0;35m\]\h\[\e[m\]:\[\e[1;34m\]\w\[\e[m\]\[\e[0;31m\]\$ \[\e[m\]'
  alias grep='grep --color=auto'
  if [ -x /usr/bin/dircolors ]; then
    eval "`dircolors -b`"
    alias ls='ls -Fh --color=auto'
  fi
else
  PS1='[\u@\h:\w]\$ '
fi

# Allow user customizations to take precedence
[ -r $HOME/.bashrc.local ] && source $HOME/.bashrc.local
