#!/bin/bash
# Description   : This script converts Windows 64-bit timestamps (number of 100-nanosecond intervals since 1/1/1601) to LDAP format (yyyyMMddhhmmssZ).
# Usage	      	: ./convertWinTimetoLDAP.sh <Win timestamp>  |  ./convertWinTimeToLDAP.sh 130645692000000000


#Convert Windows timestamp to Unix epoch format:
CONVERSION=`printf "%s\n" $((($1/10000000)-11644473600))`
#Convert Unix timestamp to LDAP timestamp:
/bin/date -u -d@"$CONVERSION" +%Y%m%d%H%M%SZ
