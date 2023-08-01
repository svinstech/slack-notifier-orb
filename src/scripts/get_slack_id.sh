#!/bin/bash

target_name=$NAME
environment_variable_name=$VARIABLE

source src/scripts/_get_slack_id.sh "$target_name" "$environment_variable_name"
echo "my_id is: $my_id"


