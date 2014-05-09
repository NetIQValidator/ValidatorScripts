#!/bin/bash
# Description   : This script adjusts LDAP timestamps (yyyyMmddhhmmssZ) based on the /bin/date conversion string that is input.
# Usage	      	: ./adjustLDAPTime.sh <LDAP timestamp> <string>  |  ./adjustLDAPTime.sh 20150101070000Z "180 days"


timestamp=$1
#Convert LDAP timestamp to a date that /bin/date can parse:
CONVERSION=`printf "%s\n" "${timestamp:0:4}-${timestamp:4:2}-${timestamp:6:2} ${timestamp:8:2}:${timestamp:10:2}:${timestamp:12:2}"`
#Convert the date back to LDAP format, with the adjustment:
/bin/date -u -d "$CONVERSION $2 $3 $4" +%Y%m%d%H%M%SZ
