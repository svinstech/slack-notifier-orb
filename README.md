## HOW TO USE THIS ORB

This orb requires that Slack webhooks for the message recipients be added as CircleCI environment variables.
These environment variables must then be used as inputs for the _channelWebhookEnvironmentVariables_ argument of the _send-slack-message_ job.

### OBTAINING WEBHOOKS

First you'll need access to a Slack app.  

Here are 2 easy ways to do this:  
1. Create your own Slack app [here](https://api.slack.com/apps)  
2. Make a Jira card on the [Quality team's Jira board](https://vouchinc.atlassian.net/jira/software/c/projects/QA/boards/74/backlog?issueLimit=100) and request to be made a collaborator on the Notifier slack app. Afterwards, you should see that app listed [here](https://api.slack.com/apps)  

Once you're in a Slack app, navigate to the _Incoming Webhooks_ section.  
From there, you can add new webhooks, or copy existing ones.  

---

## RESOURCES

[slack-notifier-orb Registry Page](https://circleci.com/developer/orbs/orb/svinstech/slack-notifier-orb) - The official registry page of this orb for all versions, executors, commands, and jobs described.

[CircleCI Orb Docs](https://circleci.com/docs/orb-intro/#section=configuration) - Docs for using, creating, and publishing CircleCI Orbs.
