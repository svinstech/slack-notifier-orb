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
read -a arr < "$lookupTableFilePath"
echo "LOOKY HERE: $arr"
echo "LOOKY HERE: ${arr[@]}"
