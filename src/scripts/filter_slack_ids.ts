
import { PopulateLookupTable } from './lookupTableFunctions'

const lookupTable:string[] = [];

async function main() {
    const notifierBotToken:string = process.argv[2] // First argument must be the notifierBotToken environment variable saved to this CircleCI project.
    const lookupTableFileName:string = process.argv[3] // Optional 2nd argument. For if you want to use a custom file name.

    const slackUserInfoFilePath:string = 'slackUserInfo.json',
        slackGroupInfoFilePath:string = 'slackGroupInfo.json',
        getSlackUserShellScriptFilePath:string = 'src/scripts/get_slack_user_info.sh',
        writeLookupTableShellScriptFilePath:string = 'src/scripts/write_lookup_table_to_file.sh',
        lookupTableFilePath:string = (lookupTableFileName) ? lookupTableFileName : 'slackIdLookupTable.txt'

    await PopulateLookupTable(lookupTable, writeLookupTableShellScriptFilePath, lookupTableFilePath, getSlackUserShellScriptFilePath, slackUserInfoFilePath, slackGroupInfoFilePath, notifierBotToken)
}


main();
