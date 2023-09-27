#!/bin/bash

getSlackUserShellScriptFilePath='src/scripts/slack_id_lookup_table_scripts/gather_slack_data.sh'
slackUserInfoFilePath='slackUserInfo.json'
slackGroupInfoFilePath='slackGroupInfo.json'
slackIdLookupGeneratorFilePath='src/scripts/slack_id_lookup_table_scripts/generate_slack_id_lookup_table.ts'

bash "${getSlackUserShellScriptFilePath}" "${!SLACK_BOT_TOKEN}" "${slackUserInfoFilePath}" "${slackGroupInfoFilePath}"
npx ts-node "${slackIdLookupGeneratorFilePath}"
