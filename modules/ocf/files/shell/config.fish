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

# ignore messages from others
mesg n

# Aliases
alias ls "ls -F --color=auto"
alias quota "quota -Qs"
alias rm "rm -I"
alias leetfish "set -gx FISH swim"
alias noobfish "set -gx FISH noob"

# Logout
function on_exit --on-process %self
    if klist > /dev/null 2>&1
        kdestroy
    end
end

# Prompt colors
function fish_prompt --description 'Write out the prompt'
    if test "$FISH" = "swim"
        set_color $fish_color_cwd; echo -n "><>  "
        set_color cyan; echo -n (prompt_pwd) ''
        set_color normal
    else
        set_color red; echo -n (whoami)
        set_color normal; echo -n '@'
        set_color purple; echo -n (hostname | cut -d . -f1) ''
        set_color cyan; echo -n (prompt_pwd)
        set_color $fish_color_cwd; echo -n "> "
        set_color normal
    end
end
