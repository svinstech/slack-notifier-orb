#!/bin/bash

lookupTableFilePath=$1
lookupTable=$2

if [ -z "$lookupTableFilePath" ]
then
    lookupTableFilePath="slackIdLookupTable.json"
fi

touch "$lookupTableFilePath"
echo "$lookupTable" > "$lookupTableFilePath"

#testing
# shellcheck disable=SC2162
read -a words <<< "these are words"
echo "LOOK HERE 1:" "${words[@]}"
read -a arr < "$lookupTableFilePath"
echo "LOOK HERE 2:" "${arr[@]}"
