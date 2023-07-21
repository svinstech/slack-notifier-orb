#!/bin/bash

if [ "$1" ]
then
    "echo 'export WHEN=\"always\"'>>$BASH_ENV"
else
    "echo 'export WHEN=\"on_fail\"'>>$BASH_ENV"
fi