#!/bin/bash

################################## ENSURE THAT CURL IS INSTALLED
apt update; apt install -y curl; 

################################## PROCESS THE SLACK MESSAGE.
variables=""
processedMessage=${MESSAGE}

if [[ $MESSAGE ]]
then
  for word in ${MESSAGE}
  do
      maxIndex=$((${#word}-1))
      firstTwoCharacters=${word:0:2}
      thirdCharacter=${word:2:1}

      if [ "$firstTwoCharacters" = "\${" ] && [ "$thirdCharacter" != "!" ]
      then
          # Find next instance of a } to indetify the end of the string interpolation.
          for index in $(seq 2 ${maxIndex})
          do
              character=${word:index:1}
              if [ "${character}" = "}" ]
              then
                  maxIndex=$((index-1))
                  break
              fi
          done

          variableName=${word:2:$((maxIndex-1))}
          variables="${variables} ${variableName}"
      fi
  done

  if [[ $variables ]]
  then
    # Replace all variables in the string with their corresponding values.
    for variable in ${variables}
    do
        processedMessage="${processedMessage//\$\{${variable}\}/${!variable}}"
    done
  fi

  # Replace all double-quotation marks with single-quotation marks. (to prevent payload errors below)
  processedMessage="${processedMessage//"\""/"'"}"
  echo "${processedMessage}"
fi
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
                      \"text\": \"${HEADER}\" \
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
