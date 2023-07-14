#!/bin/bash

################################## ENSURE THAT CURL IS INSTALLED
apt update; apt install -y curl; 

################################## PROCESS THE SLACK MESSAGE & HEADER.

# Takes 1 argument - The text to process.
# All interpolated variables in the text will be replaced with their corresponding values.
# Also, all escaped double-quotation marks will be replaced with single quotation marks.

processText () {
  local processedText=$1
  local variables=""

  if [[ $processedText ]]
  then
    for word in ${processedText}
    do
        echo "word: $word"

        regex="\\$\{(.+)\}"
        if [[ $word =~ $regex ]]
        then
            local variableName=${BASH_REMATCH[1]}

            echo "variableName: $variableName"
            echo "variable value: ${!variableName}"

            variables="${variables} ${variableName}"
        fi
    done

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

# processText () {
#   processedText=$1
#   variables=""

#   if [[ $processedText ]]
#   then
#     for word in ${processedText}
#     do
#         maxIndex=$((${#word}-1))
#         firstTwoCharacters=${word:0:2}
#         thirdCharacter=${word:2:1}

#         if [ "$firstTwoCharacters" = "\${" ] && [ "$thirdCharacter" != "!" ]
#         then
#             # Find next instance of a } to indetify the end of the string interpolation.
#             for index in $(seq 2 ${maxIndex})
#             do
#                 character=${word:index:1}
#                 if [ "${character}" = "}" ]
#                 then
#                     maxIndex=$((index-1))
#                     break
#                 fi
#             done

#             variableName=${word:2:$((maxIndex-1))}
#             variables="${variables} ${variableName}"
#         fi
#     done

#     if [[ $variables ]]
#     then
#       # Replace all variables in the string with their corresponding values.
#       for variable in ${variables}
#       do
#           processedText="${processedText//\$\{${variable}\}/${!variable}}"
#       done
#     fi

#     # Replace all double-quotation marks with single-quotation marks. (to prevent payload errors below)
#     processedText="${processedText//"\""/"'"}"
#   fi

#   echo "$processedText"
# }


processedMessage="$(processText "$MESSAGE")"
processedHeader="$(processText "$HEADER")"

echo "processedMessage: $processedMessage"
# echo "processedHeader: $processedHeader"

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
                      \"text\": \"${processedHeader}\" \
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
