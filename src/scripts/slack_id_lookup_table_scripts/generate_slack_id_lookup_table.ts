import { PopulateLookupTable } from './lookup_table_functions'

const lookupTable:string[] = [],
    slackDataDirectory = 'slackData',
    slackUserInfoFilePath:string = `${slackDataDirectory}/slackUserInfo.json`,
    slackGroupInfoFilePath:string = `${slackDataDirectory}/slackGroupInfo.json`,
    getSlackUserShellScriptFilePath:string = 'src/scripts/slack_id_lookup_table_scripts/gather_slack_data.sh',
    writeLookupTableShellScriptFilePath:string = 'src/scripts/slack_id_lookup_table_scripts/write_lookup_table_to_file.sh',
    lookupTableFilePath:string = `${slackDataDirectory}/slackIdLookupTable.txt`

PopulateLookupTable(lookupTable, writeLookupTableShellScriptFilePath, lookupTableFilePath, getSlackUserShellScriptFilePath, slackUserInfoFilePath, slackGroupInfoFilePath)
