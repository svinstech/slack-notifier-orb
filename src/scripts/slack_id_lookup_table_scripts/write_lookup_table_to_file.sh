#!/bin/bash

lookupTableFilePath=$1
lookupTable=$2
overwrite=$3

touch "$lookupTableFilePath"

if [ "$overwrite" = true ]
then
    echo "$lookupTable" > "$lookupTableFilePath"
else
    echo "$lookupTable" >> "$lookupTableFilePath"
fi
