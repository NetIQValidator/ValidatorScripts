#!/bin/bash
# Description   : This script generates a random string, with a specified length (e.g. to generate a random password).
# Usage	      	: ./generateRandomString.sh <length>  |  ./generateRandomString.sh 12


cat /dev/urandom | tr -dc 'a-zA-Z0-9-~!@#%^&*_+=`|(){}[];"<>,.?/' | fold -w $1 | head -n 1
