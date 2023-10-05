#!/bin/bash

##### INSTALL JQ IF NECESSARY #####
if [ ! -x "$(which jq)" ]
then
  apt update; apt install -y jq; 

  #testing
  echo "jq successfully installed."
fi

directoryName="test"
mkdir "$directoryName"

DESTINATION_FILE1="$directoryName/testFile1.json"
DESTINATION_FILE2="$directoryName/testFile2.json"

############### Get workflow info
curl -o "$DESTINATION_FILE1" --request GET "https://circleci.com/api/v2/workflow/${!WORKFLOW_ID}" \
  --header "circle-token: ${!TOKEN}" \
  --header "content-type: application/json"

# Get the USER_ID from the worklfow info from the 'started_by' key.
USER_ID=$(jq -r '.started_by' "$DESTINATION_FILE1")

#testing
# echo "USER_ID: $USER_ID"

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

#testing
echo "USER_NAME: $USER_NAME"
