#!/bin/bash

for webhook in ${CHANNEL_WEBHOOKS}; do
  curl -X POST -H 'Content-type: application/json' \
    --data "{ \
              \"blocks\": \
                [ \
                  { \
                    \"type\": \"header\", \
                    \"text\": { \
                      \"type\": \"plain_text\", \
                      \"text\": \"${HEADER}\" \
                    } \
                  }, \
                  { \
                    \"type\": \"section\", \
                    \"text\": \
                    { \
                      \"type\": \"mrkdwn\", \
                      \"text\": \"${MESSAGE}\" \
                    } \
                  } \
                ] \
            }" "${!webhook}"
done