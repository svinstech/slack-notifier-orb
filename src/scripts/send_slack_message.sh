#!/bin/bash

################################## ENSURE THAT CURL IS INSTALLED
if [ ! -x "$(which curl)" ]
then
  apt update; apt install -y curl; 
fi
################################## PROCESS THE SLACK MESSAGE & HEADER.

# Takes 1 argument - The text to process.
# All interpolated variables in the text will be replaced with their corresponding values.
# All tagged Slack users (like @kellen_kincaid) will be replaced with the corresponding Slack ID.
# Also, all escaped double-quotation marks will be replaced with single quotation marks.
processText () {
  local processedText=$1
  local variables=""
  local taggedNames=""
  local taggedGroups=""
  local slackIdLookupTableFilePath="slackIdLookupTable.txt"
  local slackId=""

  if [[ $processedText ]]
  then
    # Identify all interpolated variables, tagged Slack users, & tagged Slack user groups.
    for word in ${processedText}
    do
        regexVariable="\\$\{(.+)\}"
        regexTaggedName="@(.+)"
        regexTaggedGroup="!(.*)"

        if [[ $word =~ $regexVariable ]]
        then
            local variableName=${BASH_REMATCH[1]}
            variables="${variables} ${variableName}"
        elif [[ $word =~ $regexTaggedName ]]
        then
            local taggedName=${BASH_REMATCH[1]}
            taggedNames="${taggedNames} ${taggedName}"
        elif [[ $word =~ $regexTaggedGroup ]]
        then
            local taggedGroup=${BASH_REMATCH[1]}
            taggedGroups="${taggedGroups} ${taggedGroup}"
        fi
    done

    if [[ $taggedNames ]]
    then
      # Replace all taggedNames in the string with their Slack IDs.
      for name in ${taggedNames}
      do
          slackId=$(grep "^$name=" "$slackIdLookupTableFilePath")
          slackId=${slackId#*=}

          # if [[ $slackId ]]
          # then
            processedText="${processedText//@${name}/<@${slackId}>}"
          # fi
      done
    fi

    if [[ $taggedGroups ]]
    then
      # Replace all taggedGroups in the string with their Slack IDs.
      for groupHandle in ${taggedGroups}
      do
          slackId=$(grep "^$groupHandle=" "$slackIdLookupTableFilePath")
          slackId=${slackId#*=}

          # if [[ $slackId ]]
          # then
            processedText="${processedText//\!${groupHandle}/<\!subteam^${slackId}>}"
          # fi
      done
    fi

    if [[ $variables ]]
    then
      # Replace all variables in the string with their corresponding values.
      for variable in ${variables}
      do
          processedText="${processedText//\$\{${variable}\}/${!variable}}"
      done
    fi

    # Replace all double-quotation marks with single-quotation marks. (to prevent payload errors below)
    processedText="${processedText//"\""/"'"}"
  fi

  echo "$processedText"
}

processedMessage="$(processText "$MESSAGE")"
processedHeader="$(processText "$HEADER")"
##################################


################################## SEND THE SLACK MESSAGE (NOTE - the 'text' fields must not be empty. That is why there is a trailing space after ${processedMessage}.)
for webhook in ${CHANNEL_WEBHOOKS}; do
  curl -X POST -H 'Content-type: application/json' \
    --data "{ \
              \"blocks\": \
                [ \
                  { \
                    \"type\": \"header\", \
                    \"text\": { \
                      \"type\": \"plain_text\", \
                      \"text\": \"${processedHeader} \" \
                    } \
                  }, \
                  { \
                    \"type\": \"section\", \
                    \"text\": \
                    { \
                      \"type\": \"mrkdwn\", \
                      \"text\": \"${processedMessage} \" \
                    } \
                  } \
                ] \
            }" "${!webhook}"
done
##################################
