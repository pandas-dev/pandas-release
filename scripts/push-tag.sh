#!/usr/bin/env bash
set -e

cd pandas

if [[ $1 == *0 ]];
then
    TARGET="master"
else
    # v0.23.1 -> 0.23.x
    TARGET="${1:1:-1}x"
fi

set -x

git push origin ${TARGET} --follow-tags
