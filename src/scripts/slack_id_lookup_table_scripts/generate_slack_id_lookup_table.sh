#!/bin/bash

npx ts-node src/scripts/slack_id_lookup_table_scripts/generate_slack_id_lookup_table.ts "${!SLACK_BOT_TOKEN}"
