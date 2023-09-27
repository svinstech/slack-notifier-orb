#!/bin/bash

SLACK_BOT_TOKEN=${!SLACK_BOT_TOKEN}
npx ts-node src/scripts/slack_id_lookup_table_scripts/generate_slack_id_lookup_table.ts 
