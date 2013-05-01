#!/bin/sh

desktop_list='/opt/puppet/shares/contrib/desktop/desktop_list'
credentials_dir='/opt/puppet/shares/contrib/desktop/seti'
seti_url='http://setiathome.berkeley.edu/'

if [ $# -eq 0 ]; then
  echo "Requires at least one argument, e.g.,"
  echo "  on, off, halt, info"
  exit 2
fi

case "$1" in
  on) operations='allowmorework resume update' ;;
  off) operations='nomorework update' ;;
  halt) operations='nomorework suspend update' ;;
  info) command='--get_project_status' ;;
  *) command="$@" ;;
esac

while read host; do
  echo "---> $host"
  (
    cd "$credentials_dir"
    if [ -n "$operations" ]; then
      for operation in $operations; do
        boinccmd --host $host --project "$seti_url" $operation
      done
    else
      boinccmd --host $host $command
    fi
  )
done < "$desktop_list"
