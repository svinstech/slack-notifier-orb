#!/bin/bash

##### HELPER FUNCTION(S) #####
function fail {
    printf '%s\n' "$1" >&2 ## Send message to stderr.
    exit "${2-1}" ## Return a code specified by $2, or 1 by default.
}

##### INSTALL JQ IF NECESSARY #####
if [ ! -x "$(which jq)" ]
then
  apt update; apt install -y jq; 
fi

##### FILE PATH VARIABLE ASSIGNMENT #####
userJsonFile="${SLACK_DATA_DIRECTORY_PATH}/${SLACK_USER_INFO_FILE_NAME}"
groupJsonFile="${SLACK_DATA_DIRECTORY_PATH}/${SLACK_GROUP_INFO_FILE_NAME}"
lookupTableFile="${SLACK_DATA_DIRECTORY_PATH}/${SLACK_ID_LOOKUP_TABLE_FILE_NAME}"

##### CREATE FILE FOR LOOKUP TABLE #####
touch "$lookupTableFile"

###### GET STATUS OF DATA #####
userDataIsOk=$(jq ".ok" "$userJsonFile" | tr -d '"') || fail "Failed to find field: 'ok' in user data."
userGroupDataIsOk=$(jq ".ok" "$groupJsonFile" | tr -d '"') || fail "Failed to find field: 'ok' in group data."

if [ "$userDataIsOk" != "true" ]
then
    fail "Failed to gather user data"
fi

if [ "$userGroupDataIsOk" != "true" ]
then
    fail "Failed to gather group data"
fi

##### USERS #####
usersFormatted=$( jq . "$userJsonFile" \
        | jq -r '.members[] 
        | select(. | has("deleted")) 
        | select(.deleted != true) 
        | select(. | has("id")) 
        | select(. | has("profile")) 
        | select(.profile | has("first_name")) 
        | select(.profile | has("last_name")) 
        | select(.profile | has("email")) 
        | "\(.profile.first_name 
        | ascii_downcase 
        | gsub("[ _]|\\(.*\\)|'\''";""))_\(.profile.last_name 
        | ascii_downcase 
        | gsub("[ _]|\\(.*\\)|'\''";""))=\(.id)"')

##### GROUPS #####
userGroupsFormatted=$( jq . "$groupJsonFile" \
        | jq -r '.usergroups[] 
        | select(. | has("deleted_by")) 
        | select(. | has("id")) 
        | select(. | has("handle")) 
        | select(.deleted_by == null) 
        | "\(.handle | ascii_downcase 
        | gsub("^\\s+|\\s+$";"") 
        | gsub(" ";"_"))=\(.id)"')

##### WRITE LOOKUP TABLE DATA TO FILE #####
echo "$usersFormatted" >> "${lookupTableFile}"
echo "$userGroupsFormatted" >> "${lookupTableFile}"

