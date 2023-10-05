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
echo "WORKFLOW_ID length: ${#WORKFLOW_ID}"
echo "TOKEN length: ${#TOKEN}"
testWorkflowID=${!WORKFLOW_ID}
testToken=${!TOKEN}
echo "expanded WORKFLOW_ID length: ${#testWorkflowID}"
echo "expanded TOKEN length: ${#testWorkflowID}"

#testing
echo "About to do curl request"

DESTINATION_FILE="testFile.json"

curl -o "$DESTINATION_FILE" -s --request GET "https://circleci.com/api/v2/workflow/${!WORKFLOW_ID}/job" \
--header "circle-token: ${!TOKEN}" \
--header "content-type: application/json"# | jq '.items | .[] | select(.type == "approval") | {approved_by}'

#testing
echo "Finished curl request"

echo "$test"

#testing
echo "FINISHED"
