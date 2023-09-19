"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
const { readFile } = require('fs'), { execSync, exec } = require('child_process');
const lookupTable = [];
function main() {
    return __awaiter(this, void 0, void 0, function* () {
        const NOTIFIER_BOT_TOKEN = process.argv[2];
        const lookupTableFileName = process.argv[3];
        const slackUserInfoFilePath = 'slackUserInfo.json', slackGroupInfoFilePath = 'slackGroupInfo.json', getSlackUserShellScriptFilePath = 'src/scripts/get_slack_user_info.sh', writeLookupTableShellScriptFilePath = 'src/scripts/write_lookup_table_to_file.sh', lookupTableFilePath = (lookupTableFileName) ? lookupTableFileName : 'slackIdLookupTable.txt';
        execSync(`sh ${getSlackUserShellScriptFilePath} ${NOTIFIER_BOT_TOKEN} ${slackUserInfoFilePath} ${slackGroupInfoFilePath}`);
        yield readFile(slackUserInfoFilePath, { encoding: 'utf-8' }, function (err, data) {
            if (!err) {
                const slackUsersResponse = JSON.parse(data);
                if (!slackUsersResponse.ok) {
                    console.log(`!!! Error - Response object not ok (users). Error: ${slackUsersResponse.error}`);
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
                exec(`sh ${writeLookupTableShellScriptFilePath} ${lookupTableFilePath} '${lookupTable.join("\n")}' true`, (error, stdout, stderr) => {
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
        yield readFile(slackGroupInfoFilePath, { encoding: 'utf-8' }, function (err, data) {
            if (!err) {
                const slackGroupsResponse = JSON.parse(data);
                if (!slackGroupsResponse.ok) {
                    console.log(`!!! Error - Response object not ok (groups). Error: ${slackGroupsResponse.error}`);
                    return;
                }
                let slackGroups = slackGroupsResponse.usergroups;
                slackGroups.forEach((slackGroup) => {
                    const handle = slackGroup.handle;
                    const id = slackGroup.id;
                    lookupTable.push(`${handle}=${id}`);
                });
                exec(`sh ${writeLookupTableShellScriptFilePath} ${lookupTableFilePath} '${lookupTable.join("\n")}' false`, (error, stdout, stderr) => {
                    if (error) {
                        console.error(`!!! Error appending to lookup table file - ${error}`);
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
                console.log(`!!! Error reading ${slackGroupInfoFilePath} file - ${err}`);
            }
        });
    });
}
main();
