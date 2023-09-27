import { readFile } from 'fs'
import { exec } from 'child_process'
import { SlackUser, SlackGroup, SlackUsersResponseObject, SlackGroupsResponseObject } from './interfaces'

export async function PopulateLookupTable(_lookupTable:string[], _writeLookupTableShellScriptFilePath:string, _lookupTableFilePath:string, _getSlackUserShellScriptFilePath:string, _slackUserInfoFilePath:string, _slackGroupInfoFilePath:string) {
    await GetSlackData(_getSlackUserShellScriptFilePath, _slackUserInfoFilePath, _slackGroupInfoFilePath);
    // await AddUserDataToLookupTable(_lookupTable, _writeLookupTableShellScriptFilePath, _lookupTableFilePath, _slackUserInfoFilePath);
    // await AddUserGroupDataToLookupTable(_lookupTable, _writeLookupTableShellScriptFilePath, _lookupTableFilePath, _slackGroupInfoFilePath);
}

async function GetSlackData(_getSlackUserShellScriptFilePath:string, _slackUserInfoFilePath:string, _slackGroupInfoFilePath:string) {
    // Get the Slack user info.
    await exec(`sh ${_getSlackUserShellScriptFilePath} ${_slackUserInfoFilePath} ${_slackGroupInfoFilePath}`, (error:any, stdout:any, stderr:any) => {
        if (stdout) {
            console.log(`stdout: ${stdout}`);
        }

        if (stderr) {
            console.error(`stderr: ${stderr}`);
        }

        if (error) {
            throw(`!!! Error acquiring Slack data - ${error}`)
        }
    });
}

async function AddUserDataToLookupTable(_lookupTable:string[], _writeLookupTableShellScriptFilePath:string, _lookupTableFilePath:string, _slackUserInfoFilePath:string) {
    // Parse the Slack user info and add it to the lookup table.
    await readFile(_slackUserInfoFilePath, {encoding: 'utf-8'}, function(err:any, data:any){
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

                _lookupTable.push(`${name}=${id}`)
            })

            // Execute the shell script that stores the lookup table in a file.
            exec(`sh ${_writeLookupTableShellScriptFilePath} ${_lookupTableFilePath} '${_lookupTable.join("\n")}' true`, (error:any, stdout:any, stderr:any) => {
                if (stdout) {
                    console.log(`stdout: ${stdout}`);
                }

                if (stderr) {
                    console.error(`stderr: ${stderr}`);
                }

                if (error) {
                    throw(`!!! Error writing lookup table to file - ${error}`);
                }
            });
        } else {
            throw(`!!! Error reading ${_slackUserInfoFilePath} file - ${err}`);
        }
    });
}

async function AddUserGroupDataToLookupTable(_lookupTable:string[], _writeLookupTableShellScriptFilePath:string, _lookupTableFilePath:string, _slackGroupInfoFilePath:string) {
    // Parse the Slack group info and add to the lookup table.
    await readFile(_slackGroupInfoFilePath, {encoding: 'utf-8'}, function(err:any, data:any){
        if (!err) {
            const slackGroupsResponse:SlackGroupsResponseObject = JSON.parse(data);
            if (!slackGroupsResponse.ok) {
                console.log(`!!! Error - Response object not ok (groups). Error: ${slackGroupsResponse.error}`)
                return;
            }
            
            let slackGroups:SlackGroup[] = slackGroupsResponse.usergroups;

            
            
            // Populate the lookup table with name::id pairs.
            slackGroups.forEach((slackGroup:SlackGroup) => {
                // Only keep non-deleted groups.
                if (slackGroup.deleted_by == null) {
                    const handle:string = slackGroup.handle
                    const id:string = slackGroup.id;

                    _lookupTable.push(`${handle}=${id}`)
                }
            })

            // Execute the shell script that stores the lookup table in a file.
            exec(`sh ${_writeLookupTableShellScriptFilePath} ${_lookupTableFilePath} '${_lookupTable.join("\n")}' false`, (error:any, stdout:any, stderr:any) => {
                if (stdout) {
                    console.log(`stdout: ${stdout}`);
                }

                if (stderr) {
                    console.error(`stderr: ${stderr}`);
                }

                if (error) {
                    throw(`!!! Error appending to lookup table file - ${error}`)
                }
            });
        } else {
            throw(`!!! Error reading ${_slackGroupInfoFilePath} file - ${err}`);
        }
    });
}

