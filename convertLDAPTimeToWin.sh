#!/bin/bash
# Description   : This script converts LDAP timestamps (yyyyMmddhhmmssZ) to Windows 64-bit timestamps (number of 100-nanosecond intervals since 1/1/1601).
# Usage	      	: ./convertLDAPTimetoWin.sh <LDAP timestamp>  |  ./convertLDAPTimeToWin.sh 20150101070000Z


timestamp=$1
#Convert LDAP timestamp to a date that /bin/date can parse:
CONVERSION1=`printf "%s\n" "${timestamp:0:4}-${timestamp:4:2}-${timestamp:6:2} ${timestamp:8:2}:${timestamp:10:2}:${timestamp:12:2}"`
#Convert the date to Unix epoch format:
CONVERSION2=`/bin/date -u -d "$CONVERSION1" +%s`
#Convert the Unix epoch date to Windows epoch format: 
printf "%s\n" $((($CONVERSION2+11644473600)*10000000))
