#!/usr/bin/env bash

# Declaration of IPv4 set for control of address validity:
octet="(25[0-5]|2[0-4][0-9]|[01]?[0-9]?[0-9])"
ip4="^$octet\\.$octet\\.$octet\\.$octet$"

# Declaration of functions we call in body of script:
function trap_signals
{
    trap '{ echo ""; echo "Script interupted by user."; sleep 1.5; 
    	 exit $true; EXIT_SUCCESS=$?; echo $EXIT_SUCCESS 0; }' INT
    trap '{ echo "";  echo "Script paused by user."; }' TSTP
}

function dns_resolve
{
    read -p "Enter the name of a DNS server: " dns_address
    if [ "$dns_address" == "" ]
    then
	echo "Error, a name is required!"
	exit 1
    fi
}

# Here where body starts:
printf "Exit by Ctrl-C.\n"
dns_resolve

while $true:
do
    trap_signals
    answer=$(nslookup $dns_address | grep Address | awk 'NR == 2 { print $2; }' )
    if ([ -z $answer ])
    then
	echo "---------------------------------------------------------------"
	echo "$(date): -> $dns_address is >>DOWN<<. :-("
    else
	if [[ $answer =~ $ip4 ]]
	then
            echo "---------------------------------------------------------"
	    echo "$(date): -> $dns_address is UP. :-)"
	else
	    echo "---------------------------------------------------------------"
            echo "$(date): -> $dns_address is >>DOWN<<. :-("
	fi
    fi
    sleep 3
done
