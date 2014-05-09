#!/bin/bash
# Description   : This script changes strings to title case.
# Usage         : ./toTitleCase.sh <string>  |  ./toTitleCase.sh GEORGE


echo $1 | sed 's/.*/\L&/; s/[a-z]*/\u&/g'
