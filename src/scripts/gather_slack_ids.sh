#!/bin/bash

npx ts-node src/scripts/filter_slack_ids.ts "${!SLACK_BOT_TOKEN}"

#testing
# fileContents=$(cat slackIdLookupTable.txt)
# echo "Slack ID lookup table length (in characters): ${#fileContents}."
