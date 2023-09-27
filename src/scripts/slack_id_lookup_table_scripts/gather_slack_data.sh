#!/bin/bash

################################## ENSURE THAT CURL IS INSTALLED
if [ ! -x "$(which curl)" ]
then
  echo "script a 1"
  apt update; apt install -y curl; 
fi
##################################

################################## GET ALL VOUCH SLACK USER & USER GROUP INFO (saves them to a new file)
DESTINATION_FILE_USERS=$1
DESTINATION_FILE_GROUPS=$2
curl -o "$DESTINATION_FILE_USERS" -H 'Content-type: application/json' -H "Authorization: Bearer $SLACK_BOT_TOKEN" "https://slack.com/api/users.list?pretty=1"
curl -o "$DESTINATION_FILE_GROUPS" -H 'Content-type: application/json' -H "Authorization: Bearer $SLACK_BOT_TOKEN" "https://slack.com/api/usergroups.list?pretty=1"
##################################
