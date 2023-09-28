#!/bin/bash

lookupTableFilePath=$1
lookupTable=$2
overwrite=$3

if [ -z "$lookupTableFilePath" ]
then
    lookupTableFilePath="slackIdLookupTable.json"
fi

touch "$lookupTableFilePath"

if [ "$overwrite" = true ]
then
    echo "----OVERWRITING LOOKUP TABLE" >> "$lookupTableFilePath"
    echo "$lookupTable" > "$lookupTableFilePath"
else
    echo "APPENDING TO LOOKUP TABLE----" >> "$lookupTableFilePath"
    echo "$lookupTable" >> "$lookupTableFilePath"
fi
