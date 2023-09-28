import { readFileSync } from 'fs'
import { execSync } from 'child_process'
import { SlackUser, SlackGroup, SlackUsersResponseObject, SlackGroupsResponseObject } from './interfaces'

export function PopulateLookupTable(_lookupTable:string[], _writeLookupTableShellScriptFilePath:string, _lookupTableFilePath:string, _getSlackUserShellScriptFilePath:string, _slackUserInfoFilePath:string, _slackGroupInfoFilePath:string):void {
    AddUserDataToLookupTable(_lookupTable, _slackUserInfoFilePath);
    AddUserGroupDataToLookupTable(_lookupTable, _slackGroupInfoFilePath);
    WriteLookupTableToFile(_lookupTable, _writeLookupTableShellScriptFilePath, _lookupTableFilePath);
}

function AddUserDataToLookupTable(_lookupTable:string[], _slackUserInfoFilePath:string):void {
    // Parse the Slack user info and add it to the lookup table.
    let slackUserData:string;
    try {
        slackUserData = readFileSync(_slackUserInfoFilePath, {encoding: 'utf-8'})
    } catch (error:unknown) {
        throw(`!!! Error - Failed to read Slack user info file: ${_slackUserInfoFilePath}. The error: ${error}`)
    }

    const slackUsersResponse:SlackUsersResponseObject = JSON.parse(slackUserData);
    if (!slackUsersResponse.ok) {
        throw(`!!! Error - Response object not ok (users). Error: ${slackUsersResponse.error}`)
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
}

function AddUserGroupDataToLookupTable(_lookupTable:string[], _slackGroupInfoFilePath:string):void {
    // Parse the Slack group info and add to the lookup table.
    let slackUserGroupData:string;
    try {
        slackUserGroupData = readFileSync(_slackGroupInfoFilePath, {encoding: 'utf-8'})
    }  catch (error:unknown) {
        throw(`!!! Error - Failed to read Slack user group info file: ${_slackGroupInfoFilePath}. The error: ${error}`)
    }

    const slackGroupsResponse:SlackGroupsResponseObject = JSON.parse(slackUserGroupData);
    if (!slackGroupsResponse.ok) {
        throw(`!!! Error - Response object not ok (groups). Error: ${slackGroupsResponse.error}`)
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
}

function WriteLookupTableToFile(_lookupTable:string[], _writeLookupTableShellScriptFilePath:string, _lookupTableFilePath:string):void {
    // Execute the shell script that stores the lookup table in a file.
    const overwriteFile:boolean = true
    try {
        execSync(`bash ${_writeLookupTableShellScriptFilePath} ${_lookupTableFilePath} '${_lookupTable.join("\n")}' ${overwriteFile}`)
    } catch (error:unknown) {
        throw(`!!! Error - Failed to write the lookup table to this file: ${_lookupTableFilePath}. The error: ${error}`)
    }
}
