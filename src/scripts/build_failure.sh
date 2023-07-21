#!/bin/bash

echo 'export BUILD_STATUS="<<parameters.fail-text>>"'>>"$BASH_ENV"
echo 'export FAILURE=true'>>"$BASH_ENV"