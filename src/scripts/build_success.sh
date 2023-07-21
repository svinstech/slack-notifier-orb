#!/bin/bash

echo 'export BUILD_STATUS="<<parameters.pass-text>>"'>>"$BASH_ENV"
echo 'export FAILURE=false'>>"$BASH_ENV"