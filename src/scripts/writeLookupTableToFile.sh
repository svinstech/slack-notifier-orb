#!/bin/bash

lookupTableFilePath=$1
lookupTable=$2

if [ -z "$lookupTableFilePath" ]
then
    lookupTableFilePath="slackIdLookupTable.json"
fi

touch "$lookupTableFilePath"
echo "$lookupTable" > "$lookupTableFilePath"
