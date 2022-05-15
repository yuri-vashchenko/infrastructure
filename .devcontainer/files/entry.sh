#!/bin/bash -l

args=$@

if [ "$STARTDIR" != "" ];
then
    cd "$STARTDIR"
fi

eval $args

