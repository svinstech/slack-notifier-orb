#!/bin/bash

tsc src/scripts/filter_slack_ids.ts
node dist/filter_slack_ids.js $SLACK_BOT_TOKEN
