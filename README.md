## HOW TO USE THIS ORB

Firstly, create a reference this orb like this:  

    orbs:
        slack-notifier: svinstech/slack-notifier-orb

Then, you can send a Slack message like this:  

    workflows:
      send-basic-message:
        jobs:
          - slack-notifier/send-slack-message:
              header: TESTING SLACK-NOTIFICATION ORB - Basic message
              message: This is a test message
              channelWebhookEnvironmentVariables: TEST_SLACK_WEBHOOK1 TEST_SLACK_WEBHOOK2

You can see further examples in src/examples/example.yml  

### WEBHOOKS

This orb requires that Slack webhooks for the message recipients be added as CircleCI environment variables.
These environment variables must then be used as inputs for the _channelWebhookEnvironmentVariables_ argument of the _send-slack-message_ job.  

To obtain a Slack webhook, you'll need access to a Slack app.  

Here are 2 easy ways to do this:  
1. Create your own Slack app [here](https://api.slack.com/apps).  
After clicking the _Create an app_ button, you'll be asked how you'd like to configure your app's settings. Select _From scratch_.  
Then you'll asked to pick a workspace to develop your app.  Select _Vouch Insurance_ from the dropdown.  
After creating your app, you may need to request approval from a Slack admin.  
As of June 20, 2023, some Slack Admins include: Yvonne Medellin & Cody Carter.  
2. Make a Jira card on the [Quality team's Jira board](https://vouchinc.atlassian.net/jira/software/c/projects/QA/boards/74/backlog?issueLimit=100) and request to be made a collaborator on the Notifier slack app. Afterwards, you should see that app listed [here](https://api.slack.com/apps)  

Once you're in a Slack app, navigate to the _Incoming Webhooks_ section.  
From there, you can add new webhooks, or copy existing ones.  

---

## RESOURCES

[slack-notifier-orb Registry Page](https://circleci.com/developer/orbs/orb/svinstech/slack-notifier-orb) - The official registry page of this orb for all versions, executors, commands, and jobs described.

[CircleCI Orb Docs](https://circleci.com/docs/orb-intro/#section=configuration) - Docs for using, creating, and publishing CircleCI Orbs.

Feel free to reach out to Kellen Kincaid with any questions!
