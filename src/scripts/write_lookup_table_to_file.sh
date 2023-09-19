#!/bin/bash

lookupTableFilePath=$1
lookupTable=$2
overwrite=$3

if [ -z "$lookupTableFilePath" ]
then
    lookupTableFilePath="slackIdLookupTable.json"
fi

touch "$lookupTableFilePath"

if [[ $overwrite ]]
then
    echo "$lookupTable" > "$lookupTableFilePath"
else
    echo "$lookupTable" >> "$lookupTableFilePath"
fi