"use strict";
const { readFile, unlink } = require('fs'), { execSync, exec } = require('child_process');
const lookupTable = [];
const NOTIFIER_BOT_TOKEN = process.argv[2];
const lookupTableFileName = process.argv[3];
const slackUserInfoFilePath = 'slackUserInfo.json', getSlackUserShellScriptFilePath = 'src/scripts/get_slack_user_info.sh', writeLookupTableShellScriptFilePath = 'src/scripts/writeLookupTableToFile.sh', lookupTableFilePath = (lookupTableFileName) ? lookupTableFileName : 'slackIdLookupTable.txt';
execSync(`sh ${getSlackUserShellScriptFilePath} ${NOTIFIER_BOT_TOKEN}`);
readFile(slackUserInfoFilePath, { encoding: 'utf-8' }, function (err, data) {
    if (!err) {
        const slackUsersResponse = JSON.parse(data);
        if (!slackUsersResponse.ok) {
            console.log(`!!! Error - Response object not ok. Error: ${slackUsersResponse.error}`);
            return;
        }
        let slackUsers = slackUsersResponse.members;
        slackUsers = slackUsers.filter((slackUser) => {
            const userNotDeleted = !slackUser.deleted;
            const userHasFirstAndLastName = !!slackUser.profile.first_name && !!slackUser.profile.last_name;
            const userHasEmail = !!slackUser.profile.email;
            const userIsReal = userNotDeleted && userHasFirstAndLastName && userHasEmail;
            return userIsReal;
        });
        slackUsers.forEach((slackUser) => {
            let name = `${slackUser.profile.first_name.toLowerCase()}_${slackUser.profile.last_name.toLowerCase()}`.trim().replace(' ', '_');
            name = name.replace(/_?\(.*\)_?/, '');
            name = name.replace('__', '_');
            name = name.replace("'", "");
            name = name.trim();
            const id = slackUser.id;
            lookupTable.push(`${name}=${id}`);
        });
        exec(`sh ${writeLookupTableShellScriptFilePath} ${lookupTableFilePath} '${lookupTable.join("\n")}'`, (error, stdout, stderr) => {
            if (error) {
                console.error(`!!! Error writing lookup table to file - ${error}`);
                return;
            }
            if (stdout) {
                console.log(`stdout: ${stdout}`);
            }
            if (stderr) {
                console.error(`stderr: ${stderr}`);
            }
        });
    }
    else {
        console.log(`!!! Error reading ${slackUserInfoFilePath} file - ${err}`);
    }
});
