#!/bin/bash

while getopts l: opts; do
   case ${opts} in
      l) LOCATION=${OPTARG} ;;
   esac
done

if [ "$LOCATION" != "home" ] && [ "$LOCATION" != "work" ]
then
    echo "Usage: $0 -l Location: either home or work"
    exit 1
fi
