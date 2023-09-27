
import { PopulateLookupTable } from './lookup_table_functions'

const lookupTable:string[] = [];

async function main() {
    //deleteme
    console.log(`token length: ${process.env.SLACK_BOT_TOKEN?.length}`)


    const slackUserInfoFilePath:string = 'slackUserInfo.json',
        slackGroupInfoFilePath:string = 'slackGroupInfo.json',
        getSlackUserShellScriptFilePath:string = 'src/scripts/slack_id_lookup_table_scripts/gather_slack_data.sh',
        writeLookupTableShellScriptFilePath:string = 'src/scripts/slack_id_lookup_table_scripts/write_lookup_table_to_file.sh',
        lookupTableFilePath:string = 'slackIdLookupTable.txt'

    await PopulateLookupTable(lookupTable, writeLookupTableShellScriptFilePath, lookupTableFilePath, getSlackUserShellScriptFilePath, slackUserInfoFilePath, slackGroupInfoFilePath)
}


main();
