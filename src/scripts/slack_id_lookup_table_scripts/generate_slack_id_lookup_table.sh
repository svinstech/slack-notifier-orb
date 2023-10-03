#!/bin/bash

# mkdir -p "${SLACK_DATA_DIRECTORY_PATH}"
# bash "${GET_SLACK_USER_SHELL_SCRIPT_FILE_PATH}" "${!SLACK_BOT_TOKEN}" "${SLACK_DATA_DIRECTORY_PATH}/${SLACK_USER_INFO_FILE_NAME}" "${SLACK_DATA_DIRECTORY_PATH}/${SLACK_GROUP_INFO_FILE_NAME}"
# npx ts-node "${SLACK_ID_LOOKUP_GENERATOR_FILE_PATH}"

function fail {
    printf '%s\n' "$1" >&2 ## Send message to stderr.
    exit "${2-1}" ## Return a code specified by $2, or 1 by default.
}

# Install jq if necessary.
if [ ! -x "$(which jq)" ]
then
  apt update; apt install -y jq; 
fi

userJsonFile="${SLACK_DATA_DIRECTORY_PATH}/${SLACK_USER_INFO_FILE_NAME}"
groupJsonFile="${SLACK_DATA_DIRECTORY_PATH}/${SLACK_GROUP_INFO_FILE_NAME}"
lookupTableFile="${SLACK_DATA_DIRECTORY_PATH}/${SLACK_ID_LOOKUP_TABLE_FILE_NAME}"

touch "$lookupTableFile" # Create the lookup table.

#debugging
echo "1"

# Get status of data.
userDataIsOk=$(jq ".ok" $userJsonFile | tr -d '"')
userGroupDataIsOk=$(jq ".ok" $groupJsonFile | tr -d '"')

if [ "$userDataIsOk" != "true" ]
then
    fail "Failed to gather user data"
fi

if [ "$userGroupDataIsOk" != "true" ]
then
    fail "Failed to gather group data"
fi

#debugging
echo "userDataIsOk: $userDataIsOk"
echo "groupDataIsOk: $userGroupDataIsOk"

##### USERS #####
index=0
member="$(jq ".members[$index]" "$userJsonFile")"

#debugging
echo "2"
echo "member 0: $member"

# shellcheck disable=SC2236
while [ ! -z "$member" ] && [ "$member" != "null" ]
do
    # This allows the member's json to be saved to a variable and referenced directly.
    member="{key:${member}}"

    # Ensure that the member is not deleted.
    memberDeletionStatus="$(jq -n "$member" | jq .key.deleted)" # | tr -d '"')"

    # Ensure that the member is has a first name.
    memberFirstName="$(jq -n "$member" | jq .key.profile.first_name | tr -d '"')"
    memberFirstName="$(echo "$memberFirstName" | xargs)" # Trim trailing and leading whitespace.

    # Ensure that the member is has a last name.
    memberLastName="$(jq -n "$member" | jq .key.profile.last_name | tr -d '"')"
    memberLastName="$(echo "$memberLastName" | xargs)" # Trim trailing and leading whitespace.

    # Ensure that the member is has a email.
    memberEmail="$(jq -n "$member" | jq .key.profile.email | tr -d '"')"

    # Using the above info, ensure that the member is real and active.
    memberIsRealAndActive=""
    # shellcheck disable=SC2236
    if [ "$memberDeletionStatus" != "true" ] && [ ! -z "$memberFirstName" ] && [ "$memberFirstName" != "null" ] && [ ! -z "$memberLastName" ] && [ "$memberLastName" != "null" ] && [ ! -z "$memberEmail" ] && [ "$memberEmail" != "null" ]
    then
        memberIsRealAndActive="true"
    else
        memberIsRealAndActive="false"
    fi

    if [ "$memberIsRealAndActive" = "true" ] 
    then
        regexParentheses="(.*)\(.*\)(.*)"
        regexApostrophe="(.*)'(.*)"
        regexDoubleUnderscore="(.*)__(.*)"
        regexSpaceBetweenWords="(.*) +(.*)"
        memberFullName="${memberFirstName}_${memberLastName}"
        memberFullName="$(echo "$memberFullName" | tr "[:upper:]" "[:lower:]")" # Convert to lowercase.

        while [[ "$memberFullName" =~ $regexParentheses ]]; do
            memberFullName=${BASH_REMATCH[1]}${BASH_REMATCH[2]} # Remove parentheses and what they contain.
        done

        while [[ "$memberFullName" =~ $regexApostrophe ]]; do
            memberFullName=${BASH_REMATCH[1]}${BASH_REMATCH[2]} # Remove apostrophes.
        done

        # Trim trailing and leading whitespace again.
        memberFullName="$(echo "$memberFullName" | xargs)"

        while [[ "$memberFullName" =~ $regexDoubleUnderscore ]]; do
            memberFullName=${BASH_REMATCH[1]}_${BASH_REMATCH[2]} # Convert double underscores to single underscores.
        done

        while [[ "$memberFullName" =~ $regexSpaceBetweenWords ]]; do
            memberFullName=${BASH_REMATCH[1]}_${BASH_REMATCH[2]} # Convert spaces between words to single underscores.
        done

        # Get ID
        memberId="$(jq -n "$member" | jq .key.id | tr -d '"')"

        lookupTableEntry="${memberFullName}=${memberId}"

        echo "${lookupTableEntry}" >> "${lookupTableFile}"
    fi

    ((index++))
    member="$(jq ".members[$index]" "$userJsonFile")"
done
#################

#debugging
echo "3"

##### GROUPS #####
index=0
userGroups="$(jq ".usergroups" "$groupJsonFile")" # Extract usergroups json from file
userGroups="{key:${userGroups}}" # Assign usergroups json to variable so we can reference it instead of the file.
userGroup="$(jq -n "$userGroups" | jq .key["$index"])"

#debugging
echo "4"

# shellcheck disable=SC2236
while [ ! -z "$userGroup" ] && [ "$userGroup" != "null" ]
do
    # This allows the userGroup's json to be saved to a variable and referenced directly.
    userGroup="{key:${userGroup}}"

    # Ensure that the userGroup is not deleted.
    userGroupDeletionStatus="$(jq -n "$userGroup" | jq .key.deleted_by)" # | tr -d '"')"

    # Ensure that the userGroup is has an ID.
    userGroupId="$(jq -n "$userGroup" | jq .key.id | tr -d '"')"
    userGroupId="$(echo "$userGroupId" | xargs)" # Trim trailing and leading whitespace.

    # Ensure that the userGroup is has a handle.
    userGroupHandle="$(jq -n "$userGroup" | jq .key.handle | tr -d '"')"
    userGroupHandle="$(echo "$userGroupHandle" | xargs)" # Trim trailing and leading whitespace.

    # Using the above info, ensure that the userGroup is real and active.
    userGroupIsRealAndActive=""
    # shellcheck disable=SC2236
    if [ "$userGroupDeletionStatus" = "null" ] && [ ! -z "$userGroupId" ] && [ "$userGroupId" != "null" ] && [ ! -z "$userGroupHandle" ] && [ "$userGroupHandle" != "null" ]
    then
        userGroupIsRealAndActive="true"
    else
        userGroupIsRealAndActive="false"
    fi

    if [ "$userGroupIsRealAndActive" = "true" ] 
    then
        # Convert to lowercase.
        userGroupHandle="$(echo "$userGroupHandle" | tr "[:upper:]" "[:lower:]")"

        # Trim trailing and leading whitespace.
        userGroupHandle="$(echo "$userGroupHandle" | xargs)"

        lookupTableEntry=${userGroupHandle}=${userGroupId}

        echo "${lookupTableEntry}" >> "${lookupTableFile}"
    fi

    ((index++))
    userGroup="$(jq -n "$userGroups" | jq .key["$index"])"
done
##################

#debugging
echo "5"
