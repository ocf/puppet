#!/bin/bash

# Quit if no prompt
[ -z "$PS1" ] && return

# OCF environment variables
export PATH=/opt/share/utils/bin:/opt/share/utils/sbin:/usr/local/bin:\
/usr/local/sbin:/opt/puppetlabs/bin:/bin:/usr/bin:/usr/sbin:/usr/lib:/sbin:\
/usr/games
export KUBECONFIG=/etc/kubectl.conf
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Non-restrictive umask
umask 022

# ignore messages from others
mesg n

# Set up bash-completion
[ -r /etc/bash_completion ] && source /etc/bash_completion

# reset _usergroup() to prevent autocomplete lag
_usergroup() {
    return
}

# No duplicate lines in shell history
HISTCONTROL=ignoreboth
HISTTIMEFORMAT="%F %T "

# Append to history file instead of overwriting it
shopt -s histappend

# Check the window size after each command, and update LINES and COLUMNS if
# needed
shopt -s checkwinsize

# Aliases
alias ls='ls -Fh'
alias quota='/usr/bin/quota -Qs'
alias rm='rm -I'
alias cooperctl='kubectl'

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
