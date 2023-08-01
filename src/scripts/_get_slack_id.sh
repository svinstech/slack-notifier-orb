#!/bin/bash

# Enables global regex matching.
global_rematch() { 
    local s=$1 regex=$2 
    while [[ $s =~ $regex ]]; do 
        echo "${BASH_REMATCH[1]}"
        s=${s#*"${BASH_REMATCH[1]}"}
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
name_regex="\"([A-Za-z0-9_ł\-]+)\":\"@[A-Za-z0-9]+\""
id_regex="\"[A-Za-z0-9_ł\-]+\":\"(@[A-Za-z0-9]+)\""

# Get lookup table contents
lookupTableStringified=`cat slackIdLookupTable.json`

#testing
global_rematch "$lookupTableStringified" "$name_regex"
global_rematch "$lookupTableStringified" "$id_regex"

# Create arrays of names and ids
names=( "$(global_rematch "$lookupTableStringified" "$name_regex")" )
names=($names)
ids=( "$(global_rematch "$lookupTableStringified" "$id_regex")" )
ids=($ids)

name_count=${#names[@]}

# Find the ID of input_name
id=""
for name_index in "${!names[@]}"
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
else 
    echo "The ID of $input_name is $id"
fi

# Dynamically set the output variable.
declare $output_variable_name=$id

# echo "(in the main script) output_variable_name: $output_variable_name"
# echo $id
# echo "my_id: $my_id"
return 1