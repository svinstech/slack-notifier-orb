#!/bin/bash

# getSlackUserShellScriptFilePath='src/scripts/slack_id_lookup_table_scripts/gather_slack_data.sh'
# slackUserInfoFilePath='slackUserInfo.json'
# slackGroupInfoFilePath='slackGroupInfo.json'
# slackIdLookupGeneratorFilePath='src/scripts/slack_id_lookup_table_scripts/generate_slack_id_lookup_table.ts'

bash "${GET_SLACK_USER_SHELL_SCRIPT_FILE_PATH}" "${!SLACK_BOT_TOKEN}" "${SLACK_DATA_DIRECTORY_PATH}/${SLACK_USER_INFO_FILE_NAME}" "${SLACK_DATA_DIRECTORY_PATH}/${SLACK_GROUP_INFO_FILE_NAME}"
npx ts-node "${SLACK_ID_LOOKUP_GENERATOR_FILE_PATH}"
