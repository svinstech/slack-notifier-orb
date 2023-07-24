#!/bin/bash

NOTIFY_ON_SUCCESS="<<parameters.notify-on-success>>"
if [ "$NOTIFY_ON_SUCCESS" ]
then
    "echo 'export WHEN=\"always\"'>>$BASH_ENV"
else
    "echo 'export WHEN=\"on_fail\"'>>$BASH_ENV"
fi