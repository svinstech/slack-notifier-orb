#!/bin/bash

target_name=$1 #$NAME
environment_variable_name=$2 #$VARIABLE

source src/scripts/_get_slack_id.sh "$target_name" "$environment_variable_name"
echo "(parent script) my_id is: $my_id"


