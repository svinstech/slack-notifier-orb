## HOW TO USE THIS ORB

Firstly, create a reference to this orb like this:  

    orbs:
        slack-notifier: svinstech/slack-notifier-orb@1

Then, in a job of your choosing, you can send a Slack message as a step.
Here are some examples:  

    jobs:
      job-name
        docker:
          - image: cimg/base:current
        steps: 
          - slack-notifier/send-slack-message:
              header: A header for your message.
              message: The message to send. You may also use ${String} ${interpolation} with environment variables.
              channel-webhook-environment-variables: SLACK_WEBHOOK_1 SLACK_WEBHOOK_2
      job-name-2
        docker:
          - image: cimg/base:current
        steps: 
          - slack-notifier/gather-slack-ids:
              slack-bot-token: NOTIFIER_BOT_TOKEN
          - slack-notifier/build-status-notification:
              header: A header for your message.
              pass-text: Tests passed! :checkmark:
              fail-text: Failures detected! !slack-group-handle @slack-user-handle
              when: always
              additional-text: Any other text you want to include.
              channel-webhook-environment-variables: SLACK_WEBHOOK

You can see further examples in src/examples/example.yml

### WEBHOOKS & TOKENS

This orb requires that the following be added as CircleCI environment variables:
* Slack webhooks for the message recipients.
    - The Slack webhook environment variable(s) must be used as the input for the  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;_channel-webhook-environment-variables_ argument of either the _send-slack-message_   
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;command or the _build-status-notification_ command.
* The "Bot User OAuth Token" (only if you intend to tag a user or a user group).
    - The Bot User OAuth Token environment variable must be used as the input for the   
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;_slack-bot-token_ argument of the _gather-slack-ids_ command.

To obtain a Slack webhook or a Bot User OAuth Token, you'll need access to a Slack app.  

Here are 2 ways to do this:  

1. (THE EASY WAY) Make a Jira card on the [Quality team's Jira board](https://vouchinc.atlassian.net/jira/software/c/projects/QA/boards/74/backlog?issueLimit=100). In that card, request to be made a collaborator on the Slack app called Notifier. Assign the card to Kellen Kincaid or any other SDET on the Quality team. Once you've been made a collaborator, you should see that app listed [here](https://api.slack.com/apps)  

2. (THE LESS EASY WAY) If you'd rather create your own Slack app, you can do that [here](https://api.slack.com/apps).  
After clicking the _Create an app_ button, you'll be asked how you'd like to configure your app's settings. Select _From scratch_.  
Then you'll be asked to pick a workspace to develop your app.  Select _Vouch Insurance_ from the dropdown menu.  
After creating your app, you may need to request approval from a Slack admin.  
As of June 20, 2023, some Slack admins include: Yvonne Medellin & Cody Carter.  

To get a Slack webhook, navigate into the Slack app and go to the _Incoming Webhooks_ section (under 'Features'). Click the "Activate" button if the section is inactive.  
From there, you can add new webhooks, or copy existing ones.  
  
To get the Bot User OAuth Token, navigate into the Slack app and go to the _OAuth & Permissions_ section (under 'Features'). From there, the Bot User OAuth Token will be under the 'OAuth Tokens for Your Workspace' header. If you made your own Slack app, then you'll have to generate a new Bot User OAuth Token.

---

## RESOURCES

[slack-notifier-orb Registry Page](https://circleci.com/developer/orbs/orb/svinstech/slack-notifier-orb) - The official registry page of this orb for all versions, executors, commands, and jobs described.

[CircleCI Orb Docs](https://circleci.com/docs/orb-intro/#section=configuration) - Docs for using, creating, and publishing CircleCI Orbs.

[Creating a Slack app](https://api.slack.com/start/quickstart) - Docs for creating your own Slack app.

Feel free to reach out to Kellen Kincaid with any questions!
