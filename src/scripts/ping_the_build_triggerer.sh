#!/bin/bash

#testing
echo "STARTED"

##### INSTALL JQ IF NECESSARY #####
if [ ! -x "$(which jq)" ]
then
  apt update; apt install -y jq; 

  #testing
  echo "jq installed"
fi

#testing
echo "About to do curl request"

directoryName="test"
mkdir "$directoryName"

DESTINATION_FILE1="$directoryName/testFile1.json"
DESTINATION_FILE2="$directoryName/testFile2.json"
DESTINATION_FILE3="$directoryName/testFile3.json"
# DESTINATION_FILE4="$directoryName/testFile4.json"

############### Get job info
curl -o "$DESTINATION_FILE1" --request GET "https://circleci.com/api/v2/workflow/${!WORKFLOW_ID}/job" \
--header "circle-token: ${!TOKEN}" \
--header "content-type: application/json"# | jq '.items | .[] | select(.type == "approval") | {approved_by}'

############### Get workflow info
curl -o "$DESTINATION_FILE2" --request GET "https://circleci.com/api/v2/workflow/${!WORKFLOW_ID}" \
  --header "circle-token: ${!TOKEN}" \
  --header "content-type: application/json"

#TODO - Get the USER_ID from the worklfow info from the 'started_by' key.


USER_ID="2e653c6e-a61c-423c-b838-0c2e80178320"
############### Get user info
curl -o "$DESTINATION_FILE3" --request GET "https://circleci.com/api/v2/user/${USER_ID}" \
  --header "circle-token: ${!TOKEN}" \
  --header "content-type: application/json"

############### Get 








#testing
echo "Finished curl request"

#testing
echo "FINISHED"

#   --header "authorization: Basic ${!TOKEN}" 
