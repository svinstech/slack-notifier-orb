var _a = require('fs'), readFile = _a.readFile, unlink = _a.unlink, _b = require('child_process'), execSync = _b.execSync, exec = _b.exec;
var lookupTable = {};
var NOTIFIER_BOT_TOKEN = process.argv[2]; // First argument must be the NOTIFIER_BOT_TOKEN environment variable saved to this CircleCI project.
var slackUserInfoFilePath = 'slackUserInfo.json', getSlackUserShellScriptFilePath = 'src/scripts/get_slack_user_info.sh', writeLookupTableShellScriptFilePath = 'src/scripts/writeLookupTableToFile.sh', lookupTableFilePath = 'slackIdLookupTable.json';
// Execure the shell script that fetches the Slack user info.
execSync("sh ".concat(getSlackUserShellScriptFilePath, " ").concat(NOTIFIER_BOT_TOKEN));
// Parse the Slack user info to create the lookup table.
readFile(slackUserInfoFilePath, { encoding: 'utf-8' }, function (err, data) {
    if (!err) {
        var slackUsersResponse = JSON.parse(data);
        if (!slackUsersResponse.ok) {
            console.log("!!! Error - Response object not ok. Error: ".concat(slackUsersResponse.error));
            return;
        }
        var slackUsers = slackUsersResponse.members;
        // Keep only non-deleted users that have first names, last names, & emails.
        slackUsers = slackUsers.filter(function (slackUser) {
            var userNotDeleted = !slackUser.deleted;
            var userHasFirstAndLastName = !!slackUser.profile.first_name && !!slackUser.profile.last_name;
            var userHasEmail = !!slackUser.profile.email;
            var userIsReal = userNotDeleted && userHasFirstAndLastName && userHasEmail;
            return userIsReal;
        });
        // Populate the lookup table with name::id pairs.
        slackUsers.forEach(function (slackUser) {
            var name = "".concat(slackUser.profile.first_name.toLowerCase(), "_").concat(slackUser.profile.last_name.toLowerCase()).trim().replace(' ', '_');
            name = name.replace(/_?\(.*\)_?/, ''); // Remove "_(text)" from names that have them.
            name = name.replace('__', '_'); // Convert double underscores to single underscores.
            name = name.replace("'", ""); // Remove single quotes
            var id = slackUser.id;
            lookupTable[name] = id;
        });
        // Execure the shell script that stores the lookup table in a file.
        exec("sh ".concat(writeLookupTableShellScriptFilePath, " ").concat(lookupTableFilePath, " '").concat(JSON.stringify(lookupTable), "'"), function (error, stdout, stderr) {
            if (error) {
                console.error("!!! Error writing lookup table to file - ".concat(error));
                return;
            }
            if (stdout) {
                console.log("stdout: ".concat(stdout));
            }
            if (stderr) {
                console.error("stderr: ".concat(stderr));
            }
        });
    }
    else {
        console.log("!!! Error reading ".concat(slackUserInfoFilePath, " file - ").concat(err));
    }
});
