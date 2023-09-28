#!/bin/bash

mkdir "${SLACK_DATA_DIRECTORY_PATH}"
bash "${GET_SLACK_USER_SHELL_SCRIPT_FILE_PATH}" "${!SLACK_BOT_TOKEN}" "${SLACK_DATA_DIRECTORY_PATH}/${SLACK_USER_INFO_FILE_NAME}" "${SLACK_DATA_DIRECTORY_PATH}/${SLACK_GROUP_INFO_FILE_NAME}"
npx ts-node "${SLACK_ID_LOOKUP_GENERATOR_FILE_PATH}"
