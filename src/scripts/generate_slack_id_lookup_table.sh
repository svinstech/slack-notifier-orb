#!/bin/bash

function fail {
    printf '%s\n' "$1" >&2 ## Send message to stderr.
    exit "${2-1}" ## Return a code specified by $2, or 1 by default.
}

# Install jq if necessary.
if [ ! -x "$(which jq)" ]
then
  apt update; apt install -y jq; 
fi

# File and Directory names.
SLACK_DATA_DIRECTORY_PATH="slackData"
SLACK_USER_INFO_FILE_NAME="slackUserInfo.json"
SLACK_GROUP_INFO_FILE_NAME="slackGroupInfo.json"
SLACK_ID_LOOKUP_TABLE_FILE_NAME="slackIdLookupTable.txt"

# Create the slack data direcoty.
mkdir -p "${SLACK_DATA_DIRECTORY_PATH}"

# Gather the Slack data.
SLACK_BOT_TOKEN="xoxb-403261482739-5202832931136-xqP61XnYLAYU5FF6J1kuf5us"
userJsonFile="${SLACK_DATA_DIRECTORY_PATH}/${SLACK_USER_INFO_FILE_NAME}"
groupJsonFile="${SLACK_DATA_DIRECTORY_PATH}/${SLACK_GROUP_INFO_FILE_NAME}"
curl -o "$userJsonFile" -H 'Content-type: application/json' -H "Authorization: Bearer ${SLACK_BOT_TOKEN}" "https://slack.com/api/users.list?pretty=1"
curl -o "$groupJsonFile" -H 'Content-type: application/json' -H "Authorization: Bearer ${SLACK_BOT_TOKEN}" "https://slack.com/api/usergroups.list?pretty=1"

# Create file for lookup table.
lookupTableFile="${SLACK_DATA_DIRECTORY_PATH}/${SLACK_ID_LOOKUP_TABLE_FILE_NAME}"
touch "$lookupTableFile" # Create the lookup table.
echo "" > "$lookupTableFile" # Clear the lookup table if it already existed.

# Get status of data.
userDataIsOk=$(jq ".ok" "$userJsonFile" | tr -d '"')
userGroupDataIsOk=$(jq ".ok" "$groupJsonFile" | tr -d '"')

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
        | select(.deleted_by == null) 
        | select(. | has("id")) 
        | select(. | has("handle")) 
        | "\(.handle | ascii_downcase 
        | gsub("^\\s+|\\s+$";"") 
        | gsub(" ";"_"))=\(.id)"')


touch "${lookupTableFile}"
> "${lookupTableFile}"

echo "$usersFormatted" >> "${lookupTableFile}"
echo "$userGroupsFormatted" >> "${lookupTableFile}"