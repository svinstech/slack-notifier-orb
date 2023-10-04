#!/bin/bash

################################## ENSURE THAT CURL IS INSTALLED
if [ ! -x "$(which curl)" ]
then
  apt update; apt install -y curl; 
fi
##################################

################################## GET ALL VOUCH SLACK USER & USER GROUP INFO (saves them to a new file)
# SLACK_BOT_TOKEN=$1
DESTINATION_FILE_USERS="${SLACK_DATA_DIRECTORY_PATH}/${SLACK_USER_INFO_FILE_NAME}" #$2
DESTINATION_FILE_GROUPS="${SLACK_DATA_DIRECTORY_PATH}/${SLACK_GROUP_INFO_FILE_NAME}" #$3
curl -o "$DESTINATION_FILE_USERS" -H 'Content-type: application/json' -H "Authorization: Bearer ${!SLACK_BOT_TOKEN}" "https://slack.com/api/users.list?pretty=1"
curl -o "$DESTINATION_FILE_GROUPS" -H 'Content-type: application/json' -H "Authorization: Bearer ${!SLACK_BOT_TOKEN}" "https://slack.com/api/usergroups.list?pretty=1"
##################################
