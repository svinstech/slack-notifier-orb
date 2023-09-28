import { PopulateLookupTable } from './lookup_table_functions'

const lookupTable:string[] = [],
    slackUserInfoFilePath:string = `${process.env.SLACK_DATA_DIRECTORY_PATH}/${process.env.SLACK_USER_INFO_FILE_NAME}`,
    slackGroupInfoFilePath:string = `${process.env.SLACK_DATA_DIRECTORY_PATH}/${process.env.SLACK_GROUP_INFO_FILE_NAME}`,
    writeLookupTableShellScriptFilePath:string = 'src/scripts/slack_id_lookup_table_scripts/write_lookup_table_to_file.sh',
    lookupTableFilePath:string = `${process.env.SLACK_DATA_DIRECTORY_PATH}/slackIdLookupTable.txt`

PopulateLookupTable(lookupTable, writeLookupTableShellScriptFilePath, lookupTableFilePath, slackUserInfoFilePath, slackGroupInfoFilePath)
