#!/bin/bash

################################## PROCESS THE SLACK MESSAGE.
variables=""
processedMessage=${MESSAGE}

if [ -n "${MESSAGE}" ]
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
fi

if [ -n "${variables}" ]
  # Replace all variables in the string with their corresponding values.
  for variable in ${variables}
  do
      processedMessage="${processedMessage/\$\{${variable}\}/${!variable}}"
  done
fi

# echo ${processedMessage}
##################################


################################## SEND THE SLACK MESSAGE
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
                      \"text\": \"${processedMessage}\" \
                    } \
                  } \
                ] \
            }" "${!webhook}"
done
##################################
