#!/bin/bash

target_name=$NAME
environment_variable_name=$VARIABLE

# shellcheck disable=SC1091
source src/scripts/_get_slack_id.sh "$target_name" "$environment_variable_name"

# At this point, the string contained within environment_variable_name will have been used to create a 
#   variable with it as the name.
# This new variable will be accessible by this script and will contain the ID that corresponds to the name in 
#   target_name.
# For example, if target_name contains the string "kellen_kincaid" and environment_variable_name contains the
#    string "my_id", then a variable will be created called my_id and it will contain the ID of Kellen Kincaid.
# This variable can then be used in the CircleCI config within the job that called this script.
