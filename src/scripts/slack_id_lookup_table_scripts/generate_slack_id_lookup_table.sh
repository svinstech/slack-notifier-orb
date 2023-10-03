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

# Get status of data.
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
index=0
member="$(jq ".members[$index]" "$userJsonFile")"

# shellcheck disable=SC2236
while [ ! -z "$member" ] && [ "$member" != "null" ]
do
    # This allows the member's json to be saved to a variable and referenced directly.
    member="{key:${member}}"

    # Ensure that the member is not deleted.
    memberDeletionStatus="$(jq -n "$member" | jq .key.deleted)" || fail "Failed to find field: 'deleted' in user data."

    # Ensure that the member is has a first name.
    memberFirstName="$(jq -n "$member" | jq .key.profile.first_name | tr -d '"')" || fail "Failed to find field: 'profile.first_name' in user data."
    memberFirstName="$(echo "$memberFirstName" | xargs -0)" # Trim trailing and leading whitespace.

    # Ensure that the member is has a last name.
    memberLastName="$(jq -n "$member" | jq .key.profile.last_name | tr -d '"')" || fail "Failed to find field: 'profile.last_name' in user data."
    memberLastName="$(echo "$memberLastName" | xargs -0)" # Trim trailing and leading whitespace.

    # Ensure that the member is has a email.
    memberEmail="$(jq -n "$member" | jq .key.profile.email | tr -d '"')" || fail "Failed to find field: 'profile.email' in user data."

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
        memberFullName="$(echo "$memberFullName" | xargs -0)"

        while [[ "$memberFullName" =~ $regexDoubleUnderscore ]]; do
            memberFullName=${BASH_REMATCH[1]}_${BASH_REMATCH[2]} # Convert double underscores to single underscores.
        done

        while [[ "$memberFullName" =~ $regexSpaceBetweenWords ]]; do
            memberFullName=${BASH_REMATCH[1]}_${BASH_REMATCH[2]} # Convert spaces between words to single underscores.
        done

        # Get ID
        memberId="$(jq -n "$member" | jq .key.id | tr -d '"')" || fail "Failed to find field: 'id' in user data."

        lookupTableEntry="${memberFullName}=${memberId}"

        echo "${lookupTableEntry}" >> "${lookupTableFile}"
    fi

    index=$((index+1))
    member="$(jq ".members[$index]" "$userJsonFile")" || fail "Failed getting Slack user with index: $index."
done
#################

##### GROUPS #####
index=0
userGroups="$(jq ".usergroups" "$groupJsonFile")" # Extract usergroups json from file
userGroups="{key:${userGroups}}" # Assign usergroups json to variable so we can reference it instead of the file.
userGroup="$(jq -n "$userGroups" | jq .key["$index"])"

# shellcheck disable=SC2236
while [ ! -z "$userGroup" ] && [ "$userGroup" != "null" ]
do
    # This allows the userGroup's json to be saved to a variable and referenced directly.
    userGroup="{key:${userGroup}}"

    # Ensure that the userGroup is not deleted.
    userGroupDeletionStatus="$(jq -n "$userGroup" | jq .key.deleted_by)" || fail "Failed to find field: 'deleted_by' in group data."

    # Ensure that the userGroup is has an ID.
    userGroupId="$(jq -n "$userGroup" | jq .key.id | tr -d '"')" || fail "Failed to find field: 'id' in group data."
    userGroupId="$(echo "$userGroupId" | xargs -0)" # Trim trailing and leading whitespace.

    # Ensure that the userGroup is has a handle.
    userGroupHandle="$(jq -n "$userGroup" | jq .key.handle | tr -d '"')" || fail "Failed to find field: 'handle' in group data."
    userGroupHandle="$(echo "$userGroupHandle" | xargs -0)" # Trim trailing and leading whitespace.

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
        userGroupHandle="$(echo "$userGroupHandle" | xargs -0)"

        lookupTableEntry=${userGroupHandle}=${userGroupId}

        echo "${lookupTableEntry}" >> "${lookupTableFile}"
    fi

    index=$((index+1))
    userGroup="$(jq -n "$userGroups" | jq .key["$index"])" || fail "Failed getting Slack group with index: $index."
done
##################
