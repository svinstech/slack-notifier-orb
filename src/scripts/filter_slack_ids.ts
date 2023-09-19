
const { readFile } = require('fs'),
      { execSync, exec } = require('child_process'); 

interface Profile {
    first_name:string,
    last_name:string,
    email:string
}

interface SlackUser {
    name:string,
    id:string,
    deleted:boolean,
    profile:Profile
}

interface SlackGroup {
    handle:string,
    id:string,
    deleted_by:string|null
}

interface SlackUsersResponseObject {
    ok:boolean,
    members:SlackUser[],
    error?:string
}

interface SlackGroupsResponseObject {
    ok:boolean,
    usergroups:SlackGroup[],
    error?:string
}

const lookupTable:string[] = [];

async function main() {
    const NOTIFIER_BOT_TOKEN:string = process.argv[2] // First argument must be the NOTIFIER_BOT_TOKEN environment variable saved to this CircleCI project.
    const lookupTableFileName:string = process.argv[3] // Optional 2nd argument. For if you want to use a custom file name.

    const slackUserInfoFilePath:string = 'slackUserInfo.json',
        slackGroupInfoFilePath:string = 'slackGroupInfo.json',
        getSlackUserShellScriptFilePath:string = 'src/scripts/get_slack_user_info.sh',
        writeLookupTableShellScriptFilePath:string = 'src/scripts/write_lookup_table_to_file.sh',
        lookupTableFilePath:string = (lookupTableFileName) ? lookupTableFileName : 'slackIdLookupTable.txt'

    // Execute the shell script that fetches the Slack user info.
    execSync(`sh ${getSlackUserShellScriptFilePath} ${NOTIFIER_BOT_TOKEN} ${slackUserInfoFilePath} ${slackGroupInfoFilePath}`);

    // Parse the Slack user info to create the lookup table.
    await readFile(slackUserInfoFilePath, {encoding: 'utf-8'}, function(err:any, data:any){
        if (!err) {
            const slackUsersResponse:SlackUsersResponseObject = JSON.parse(data);
            if (!slackUsersResponse.ok) {
                console.log(`!!! Error - Response object not ok (users). Error: ${slackUsersResponse.error}`)
                return;
            }
            
            let slackUsers:SlackUser[] = slackUsersResponse.members;

            // Keep only non-deleted users that have first names, last names, & emails.
            slackUsers = slackUsers.filter((slackUser:SlackUser) => {
                const userNotDeleted:boolean = !slackUser.deleted
                const userHasFirstAndLastName:boolean = !!slackUser.profile.first_name && !!slackUser.profile.last_name
                const userHasEmail:boolean = !!slackUser.profile.email

                const userIsReal:boolean = userNotDeleted && userHasFirstAndLastName && userHasEmail

                return userIsReal
            })
            
            // Populate the lookup table with name::id pairs.
            slackUsers.forEach((slackUser:SlackUser) => {
                let name:string = `${slackUser.profile.first_name.toLowerCase()}_${slackUser.profile.last_name.toLowerCase()}`.trim().replace(' ','_');
                name = name.replace(/_?\(.*\)_?/,'') // Remove "_(text)" from names that have them.
                name = name.replace('__','_') // Convert double underscores to single underscores.
                name = name.replace("'","") // Remove single quotes
                name = name.trim(); // Trim again, in case the changes left spaces on either end.

                const id:string = slackUser.id;

                lookupTable.push(`${name}=${id}`)
            })

            // Execute the shell script that stores the lookup table in a file.
            exec(`sh ${writeLookupTableShellScriptFilePath} ${lookupTableFilePath} '${lookupTable.join("\n")}' true`, (error:any, stdout:any, stderr:any) => {
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
        } else {
            console.log(`!!! Error reading ${slackUserInfoFilePath} file - ${err}`);
        }
    });

    // Parse the Slack group info and add to the lookup table.
    await readFile(slackGroupInfoFilePath, {encoding: 'utf-8'}, function(err:any, data:any){
        if (!err) {
            const slackGroupsResponse:SlackGroupsResponseObject = JSON.parse(data);
            if (!slackGroupsResponse.ok) {
                console.log(`!!! Error - Response object not ok (groups). Error: ${slackGroupsResponse.error}`)
                return;
            }
            
            let slackGroups:SlackGroup[] = slackGroupsResponse.usergroups;

            
            
            // Populate the lookup table with name::id pairs.
            slackGroups.forEach((slackGroup:SlackGroup) => {
                const handle:string = slackGroup.handle
                const id:string = slackGroup.id;

                lookupTable.push(`${handle}=${id}`)
            })

            // Execute the shell script that stores the lookup table in a file.
            exec(`sh ${writeLookupTableShellScriptFilePath} ${lookupTableFilePath} '${lookupTable.join("\n")}' false`, (error:any, stdout:any, stderr:any) => {
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
        } else {
            console.log(`!!! Error reading ${slackGroupInfoFilePath} file - ${err}`);
        }
    });
}


main();
