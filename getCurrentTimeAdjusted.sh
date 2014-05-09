#!/bin/bash
# Description   : This script prints the current system time in LDAP format (UTC), and adjusts based on the /bin/date conversion string specified.
# Usage	      	: ./getCurrentTimeAdjusted.sh <Date string>  |  ./getCurrentTimeAdjusted "1 week ago"


/bin/date -u --date="$1 $2 $3 $4" +%Y%m%d%H%M%SZ
