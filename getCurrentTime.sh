#!/bin/bash
# Description   : This script prints the current system time in LDAP format (UTC).
# Usage         : ./getCurrentTime.sh

/bin/date -u +%Y%m%d%H%M%SZ
