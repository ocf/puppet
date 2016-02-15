#!/bin/bash

pkusers --config /etc/pykota/pykota.semester -L $1 > /dev/null #test run of pkusers if the user exists in the database
if [[ $? -ne 0 ]]
then
   pkusers --config /etc/pykota/pykota.semester -l balance -b 100.0 -a $1
fi

page_total=`pkusers --config /etc/pykota/pykota.semester -L $1 | grep 'Account balance' | cut -d':' -f2 | sed 's/ //g' | cut -d'.' -f1`
if [[ $(date +%u) -gt 5 ]] ; then
	if [ $page_total -gt 15 ]; then
    		/usr/local/bin/autopykota --initbalance 16.0
	else
    		/usr/local/bin/autopykota --initbalance $page_total
	fi
else
	if [ $page_total -gt 7 ]; then
                /usr/local/bin/autopykota --initbalance 8.0
        else
                /usr/local/bin/autopykota --initbalance $page_total
        fi
fi
