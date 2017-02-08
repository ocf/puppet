klist &> /dev/null
if [ $? = 0 ]; then
  kdestroy
fi

PS1=''

if [ "$SHLVL" = 1 ]; then
  if [ -x /usr/bin/clear_console ]; then
    /usr/bin/clear_console -q
  fi
fi
