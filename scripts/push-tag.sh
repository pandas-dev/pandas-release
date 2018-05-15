#!/usr/bin/env bash
set -e

if [[ $1 == *0 ]];
then
    TARGET="upstream/master"
else
    # v0.23.1 -> 0.23.x
    TARGET="${1:1:-1}x"
fi

set -x

echo "git push ${TARGET} --follow-tags"
git push ${TARGET} --follow-tags
