#!/bin/bash

# SLACK_BOT_TOKEN=${!SLACK_BOT_TOKEN}
getSlackUserShellScriptFilePath='src/scripts/slack_id_lookup_table_scripts/gather_slack_data.sh'
slackUserInfoFilePath='slackUserInfo.json'
slackGroupInfoFilePath='slackGroupInfo.json'

bash "${getSlackUserShellScriptFilePath}" "${!SLACK_BOT_TOKEN}" "${slackUserInfoFilePath}" "${slackGroupInfoFilePath}"
npx ts-node src/scripts/slack_id_lookup_table_scripts/generate_slack_id_lookup_table.ts 
