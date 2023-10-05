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


DESTINATION_FILE1="test/testFile1.json"
DESTINATION_FILE2="test/testFile2.json"
# DESTINATION_FILE3="testFile3.json"
# DESTINATION_FILE4="testFile4.json"

############### Get workflow info
curl -o "$DESTINATION_FILE1" --request GET "https://circleci.com/api/v2/workflow/${!WORKFLOW_ID}/job" \
--header "circle-token: ${!TOKEN}" \
--header "content-type: application/json"# | jq '.items | .[] | select(.type == "approval") | {approved_by}'

############### Get workflow info
curl -o "$DESTINATION_FILE2" --request GET "https://circleci.com/api/v2/workflow/${!WORKFLOW_ID}" \
  --header "authorization: Basic ${!TOKEN}" \
  --header "content-type: application/json"

############### Get user info
# curl --request GET \
#   --url "https://circleci.com/api/v2/user/<USER_ID>" \
#   --header "authorization: Basic ${!TOKEN}"

############### Get 








#testing
echo "Finished curl request"

#testing
echo "FINISHED"
