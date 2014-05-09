#!/bin/bash
# Description   : This script generates random given names, surnames and full names, randomly taken from text files that contain hundreds of first and last names.
# Usage         : ./generateRandomName.sh given  |  ./generateRandomName.sh surname  |  ./generateRandomName.sh full


WD=`/bin/pwd`
GIVEN="$WD/givenNames"
SURNAME="$WD/surnames"


case "$1" in
    given)
        shuf -n 1 $GIVEN
        ;;
    surname)
        shuf -n 1 $SURNAME
        ;;
    full)
        FIRST=`shuf -n 1 $GIVEN`
        LAST=`shuf -n 1 $SURNAME`
        printf "%s\n" "$FIRST $LAST"
        ;;
    *)
        echo "Usage: $0 {given|surname|full}"
        exit 1
        ;;
esac
