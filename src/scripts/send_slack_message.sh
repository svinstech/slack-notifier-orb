#!/bin/bash

for webhook in ${CHANNEL_WEBHOOKS}; do
  if [[ $MESSAGE_DYNAMIC == "" ]]; then
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
                        \"text\": \"${MESSAGE_STATIC}\" \
                      } \
                    } \
                  ] \
              }" "${!webhook}"
  else
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
                        \"text\": \"${!MESSAGE_DYNAMIC}\" \
                      } \
                    } \
                  ] \
              }" "${!webhook}"
  fi
done