#!/bin/bash

##### INSTALL JQ IF NECESSARY #####
if [ ! -x "$(which jq)" ]
then
  apt update; apt install -y jq; 
  echo "jq successfully installed."
fi

directoryName="test"
mkdir "$directoryName"

DESTINATION_FILE1="$directoryName/testFile1.json"
DESTINATION_FILE2="$directoryName/testFile2.json"

#deleteme
curl -o "$DESTINATION_FILE1" --request GET "https://circleci.com/api/v2/workflow/269f2bae-86f7-4e94-bc10-d5abf4766590" \
  --header "circle-token: ${!TOKEN}" \
  --header "content-type: application/json"

############### Get workflow info
# curl -o "$DESTINATION_FILE1" --request GET "https://circleci.com/api/v2/workflow/${!WORKFLOW_ID}" \
#   --header "circle-token: ${!TOKEN}" \
#   --header "content-type: application/json"

# Get the USER_ID from the worklfow info from the 'started_by' key.
USER_ID=$(jq -r '.started_by' "$DESTINATION_FILE1")

############### Get user info
curl -o "$DESTINATION_FILE2" --request GET "https://circleci.com/api/v2/user/${USER_ID}" \
  --header "circle-token: ${!TOKEN}" \
  --header "content-type: application/json"

# Extract 'login' value and convert it from PascalCase to snake_case.
USER_NAME=$(jq . "$DESTINATION_FILE2" \
        | jq -r '.login 
        | "\(.)" 
        | gsub("(?<a>[A-Z])"; "_\(.a
        | ascii_downcase)") 
        | gsub("^_"; "")')

echo "USER_NAME: $USER_NAME"

# Assign the name to a new environment variable. Notice that it's prepended with an @. This is to tag that person.
echo "export BUILD_TRIGGERER='@$USER_NAME'">>"$BASH_ENV"
