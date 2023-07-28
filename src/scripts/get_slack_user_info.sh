#!/bin/bash

################################## ENSURE THAT CURL IS INSTALLED
if [ ! -x '$(which curl)' ]
then
  echo "script a 1"
  apt update; apt install -y curl; 
fi
##################################

################################## GET ALL VOUCH SLACK USER INFO (saves them to a new file)
destinationFile='slackUserInfo.json'
curl -o $destinationFile -H 'Content-type: application/json' -H 'Authorization: Bearer xoxb-403261482739-5202832931136-N8vvMYgODAysCQLbl4z1zP4D' 'https://slack.com/api/users.list?pretty=1'
##################################

