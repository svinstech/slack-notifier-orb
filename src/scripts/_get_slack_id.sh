#!/bin/bash

temporaryFileForNames="deleteme_names.txt"
temporaryFileForIds="deleteme_ids.txt"

# Enables global regex matching.
global_rematch() { 
    local string=$1 regex=$2 outputFile=$3
    while [[ $string =~ $regex ]]; do 
        printf %s "${BASH_REMATCH[1]} " >> "$outputFile"
        string=${string#*"${BASH_REMATCH[1]}"}
    done
}

# Process inputs
input_name=$1
output_variable_name=$2

# The name whose id to get.
if [[ -z "$input_name" ]]
then
    echo "First argument must be the name of the target."
    exit 1
fi

if [[ -z $output_variable_name ]]
then
    echo "Second argument must be the name of the variable in which the ID will be stored."
    exit 1
fi

# Regex expressions
character_matcher="[A-Za-z0-9_ł\-]+"
name_regex="\"($character_matcher)\":\"@$character_matcher\""
id_regex="\"$character_matcher\":\"(@$character_matcher)\""

# Get lookup table contents
lookupTableStringified=`cat slackIdLookupTable.json`

# Create arrays of names and ids
( "$(global_rematch "$lookupTableStringified" "$name_regex" "$temporaryFileForNames")" )
names=`cat $temporaryFileForNames`
names=($names)

( "$(global_rematch "$lookupTableStringified" "$id_regex" "$temporaryFileForIds")" )
ids=`cat $temporaryFileForIds`
ids=($ids)

# Find the ID of input_name
id=""
for name_index in ${!names[@]}
do
    name="${names[$name_index]}"

    if [ "$input_name" = "$name" ]
    then
        id="${ids[$name_index]}"
        break
    fi
done

# Error handling - Name not found
if [[ -z "$id" ]]
then
    echo "Name not found ($input_name). Make sure it's all lowercase and use underscores instead of spaces. Like this: first_last"
    exit 1
fi

# Dynamically set the output variable.
declare "$output_variable_name"="$id"

# These files are used to store the output of the global_rematch function. 
# The motivation to store the output in temporary files was to prevent the output from
#   cluttering the terminal.
rm "$temporaryFileForNames"
rm "$temporaryFileForIds"

return 1