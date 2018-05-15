#!/usr/bin/env bash
set -e

if [[ $1 == v* ]];
then
	cd pandas
	git fetch origin
	git reset --hard origin/master
	git clean -xdf
	echo "Creating tag: $1"
	git commit --allow-empty -m "RLS: ${1:1}"
	git tag -a $1 -m "Version ${1:1}"
else
	echo "Invalid tag $1"
    echo "Must be formatted like vX.X.X"
	exit 1
fi
